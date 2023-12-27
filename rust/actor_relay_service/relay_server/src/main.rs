#![allow(non_snake_case, unused_variables, unused_mut, unused_imports)]

use derive_more::Display;
use futures::future::err;
use log::debug;
use paris::{error, info, warn, Logger};
use serde::{Deserialize, Serialize};
use std::clone;
use std::collections::HashMap;
use std::process::id;
use std::sync::Arc;
use std::time::Duration;
use tokio::io::{AsyncBufReadExt, AsyncReadExt, AsyncWriteExt, WriteHalf};
use tokio::net::{TcpListener, TcpStream};
use tokio::sync::{mpsc, Mutex, MutexGuard};
use tokio::time::timeout;
use uuid::Uuid;
type AnyResult = anyhow::Result<()>;

pub const ADDR: &str = "0.0.0.0:8080";

#[derive(Debug, Display, Clone, Copy, Serialize, Deserialize, Eq, PartialEq, Hash)]
pub struct ClientId(Uuid);

impl ClientId {
    pub fn new() -> Self {
        Self(Uuid::new_v4())
    }

    pub fn get(&self) -> Uuid {
        self.0
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ClientMessage {
    pub clientOperation: ClientOperation,
    pub message: Option<String>,
    pub clientId: Option<ClientId>,
    pub mailbox: Option<String>, //like "default"
}

#[derive(Debug, Clone, Serialize, Deserialize)]
enum ServerOperation {
    ClientConnectApproved(ClientId),
    RequestCurrentTaskStep,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
enum ClientOperation {
    ClientConnectAttempt,
    Drop,
    ClientMessage,
}

pub struct Client {
    pub tx: mpsc::UnboundedSender<String>,
    pub clientId: ClientId,
}

impl Client {
    fn new(clientId: ClientId, tx: mpsc::UnboundedSender<String>) -> Self {
        Self { tx, clientId }
    }
}

struct Server {
    pub clients: HashMap<ClientId, Client>,
    pub writers: HashMap<ClientId, WriteHalf<TcpStream>>,
}

#[tokio::main]
async fn main() -> AnyResult {
    let mut log = Logger::new();
    let listener = TcpListener::bind(&ADDR).await?;
    let server = Arc::new(Mutex::new(Server {
        clients: HashMap::new(),
        writers: HashMap::new(),
    }));

    //let mut clientStreams: HashMap<ClientId, Arc<Mutex<TcpStream>>> = HashMap::new();

    info!("Listening on {}", &ADDR);

    loop {
        let (mut stream, _) = listener.accept().await?;
        info!("Received connection attempt from client");

        let server = Arc::clone(&server);

        let (reader, writer) = tokio::io::split(stream);

        // Spawn task for each client connection
        tokio::spawn(async move {
            let (mut tx, mut rx) = mpsc::unbounded_channel();
            let clientId = ClientId::new();
            {
                let mut server = server.lock().await;
                server
                    .clients
                    .insert(clientId.clone(), Client::new(clientId.clone(), tx.clone()));
                server.writers.insert(clientId.clone(), writer);
            }

            // Spawn a task to listen for messages to send to the client
            let server_clone = Arc::clone(&server);
            let clientIdClone = clientId.clone();

            tokio::spawn(async move {
                while let Some(message) = rx.recv().await {
                    let mut server = server_clone.lock().await;
                    if let Some(writer) = server.writers.get_mut(&clientIdClone) {
                        if let Err(e) = writer.write_all(message.as_bytes()).await {
                            error!(
                                "Failed to write message to client {}: {}",
                                clientId.clone().0,
                                e
                            );
                        }
                    }
                }
            });

            let mut buf = vec![];
            let mut reader = tokio::io::BufReader::new(reader);

            loop {
                buf.clear();
                let _ = reader.read_until(b'\n', &mut buf).await;

                info!("Deserializing from string");
                let json_message = String::from_utf8_lossy(&buf)
                    .trim()
                    .trim_end_matches('\n')
                    .to_string();
                info!("JSON Message is: {}", &json_message);
                let message: Result<ClientMessage, _> = serde_json::from_str(&json_message);
                match message {
                    Ok(message) => match message.clientOperation {
                        ClientOperation::ClientMessage => {
                            // info!(
                            //     "Received client message: {} to mailbox: {}",
                            //     message.message.unwrap(),
                            //     message.mailbox.unwrap()
                            // );
                            // We need to send this client message out to every single stream in all the tokio spawns
                            if let Some(msg) = message.message.clone() {
                                // Clone the message here
                                info!(
                                    "Received client message: {} to mailbox: {}",
                                    &msg,
                                    message.mailbox.as_deref().unwrap_or("default")
                                );
                                // We need to send this client message out to every single stream in all the tokio spawns
                                let server_guard = server.lock().await;
                                let responseMsg = format!("{} RESPONSE", msg.clone());
                                for (other_client_id, other_client) in server_guard.clients.iter() {
                                    //Commented so that it'll broadcast to every client period including itself
                                    //if *other_client_id != clientId {
                                    // Use the cloned message
                                    if let Err(e) = other_client.tx.send(responseMsg.clone()) {
                                        // Clone again for each send
                                        error!(
                                            "Failed to send message to client {}: {}",
                                            other_client_id, e
                                        );
                                    } else {
                                        info!("Sent message to client: {}", other_client_id)
                                    }
                                    //}
                                }
                            }
                        }
                        ClientOperation::Drop => {
                            info!("The client has terminated the connection.");
                            break;
                        }
                        ClientOperation::ClientConnectAttempt => {
                            info!("In clientannounce");

                            let tx_clone = tx.clone();
                            {
                                let mut server = server.lock().await;
                                server.clients.insert(
                                    clientId.clone(),
                                    Client::new(clientId.clone(), tx_clone),
                                );
                            }

                            // send client its new ID back
                            let server_operation =
                                ServerOperation::ClientConnectApproved(clientId.clone());
                            let operation_json = match serde_json::to_string(&server_operation) {
                                Ok(str) => str,
                                Err(err) => {
                                    error!(
                                        "Error occurred when serializing server operation: {}",
                                        err
                                    );
                                    continue;
                                }
                            };

                            info!("Writing to client stream");
                            // Write to the client's stream within the server lock scope
                            let mut server = server.lock().await;
                            if let Some(writer) = server.writers.get_mut(&clientId) {
                                if let Err(e) = writer.write_all(operation_json.as_bytes()).await {
                                    error!("Failed to write to client {}: {}", clientId, e);
                                } else {
                                    info!("Sent client response");
                                }
                            } else {
                                error!("Writer for client ID not found");
                            }
                            // let tx_clone = tx.clone();
                            // {
                            //     let mut server = server.lock().await;
                            //     server.clients.insert(
                            //         clientId.clone(),
                            //         Client::new(clientId.clone(), tx_clone),
                            //     );
                            // }
                            //
                            // // send client its new ID back
                            // let server_operation =
                            //     ServerOperation::ClientConnectApproved(clientId.clone());
                            // let operation_json = match serde_json::to_string(&server_operation) {
                            //     Ok(str) => str,
                            //     Err(err) => {
                            //         error!(
                            //             "Error occurred when serializing server operation: {}",
                            //             err
                            //         );
                            //         continue;
                            //     }
                            // };
                            //
                            // info!("Writing to client stream");
                            // stream.write_all(operation_json.as_bytes()).await.unwrap();
                            // info!("Sent client response");
                        }
                    },
                    Err(err) => {
                        error!("Failed to parse the message: {}", err);
                        break;
                    }
                }
            }
        });
    }
}
