use serde::{Deserialize, Serialize};
//use serde_cbor::{from_slice, to_vec};
use cbor4ii::serde::{from_slice, to_vec};

use std::{
    io::{self, Write},
    time::Duration,
};
use tokio::{net::windows::named_pipe::ServerOptions, task::JoinHandle};
use tokio::{
    io::{AsyncReadExt, AsyncWriteExt},
    time,
};
use tracing::{debug, info, warn, error};

use crate::protocol::{Room, ZMessage, ZMessageBuilder, ZMessageType};
const PIPE_NAME: &str = r"\\.\pipe\zenactorpipe";
const MAX_CLIENTS: usize = 72;

#[derive(Debug, Deserialize, Serialize)]
struct KeepAliveMsg {
    pub KeepAlive: Option<()>,
}

type AnyResult = anyhow::Result<()>;

pub async fn start_server() -> anyhow::Result<()> {
    // The first server needs to be constructed early so that clients can
    // be correctly connected. Otherwise calling .wait will cause the client to
    // error.
    //
    // Here we also make use of `first_pipe_instance`, which will ensure that
    // there are no other servers up and running already.
    let mut server = ServerOptions::new()
        .first_pipe_instance(true)
        .access_inbound(true)
        .access_outbound(true)
        //.access_system_security(true)
        .max_instances(MAX_CLIENTS as usize)
        .create(PIPE_NAME)?;

    let server = tokio::spawn(async move {
        // Artificial workload.
        time::sleep(Duration::from_secs(1)).await;
        
        for _ in 0..MAX_CLIENTS {
            // Wait for client to connect.
            server.connect().await?;
            info!("Client connected!");
            let mut inner = server;
            
            // Construct the next server to be connected before sending the one
            // we already have of onto a task. This ensures that the server
            // isn't closed (after it's done in the task) before a new one is
            // available. Otherwise the client might error with
            // `io::ErrorKind::NotFound`.
            server = ServerOptions::new().create(PIPE_NAME)?;
            
            info!("Creating client read thread");
            let _: JoinHandle<AnyResult> = tokio::spawn(async move {
                loop {
                    info!("in client read thread reading...");
                    let mut buf = vec![0u8; 4096];
                    //inner.read_exact(&mut buf).await?;
                    let buf_size = inner.read(&mut buf).await?;
                    buf.truncate(buf_size);
                    //debug!("Received: {:?}", buf);
                    //debug!("Received as UTF: {:?}", String::from_utf8_lossy(&buf));
                    let keep_alive: Result<KeepAliveMsg, cbor4ii::serde::DecodeError<_>> = from_slice(&buf);
                    // If keep_alive is an error, break from this loop because the connection died
                    // we'll automatically reconnect in a separate thread we started earlier that's listening already
                    let keep_alive = match keep_alive {
                        Ok(keep_alive) => keep_alive,
                        Err(e) => {
                            warn!("Connection dropped! Error decoding KeepAliveMsg: {:?}", e);
                            break;
                        }
                    };
                    
                    debug!("Received as KeepAliveMsg: {:?}", keep_alive);

                    let new_keepalive = KeepAliveMsg {
                        KeepAlive: Some(()),
                    };
                    //let serialized = to_vec(vec![], &new_keepalive).expect("Failed to serialize KeepAlive");
                    
                    //let msg = ZMessage {
                    //    mode: crate::protocol::MQRequestMode::SimpleMessage,
                    //    sequence_id: 0,
                    //    message_type: ZMessageType::MsgRoomConnectionRequest(Room("biggerlib".to_string())),
                    //    payload: None,
                    //};
                    //let serialized = to_vec(vec![], &msg).expect("Failed to serialize ZMessage");
                    
                    let message = ZMessageBuilder::new_mq_command_string("/say TEST FROM WEB".into()).build()?;
                    let serialized = serialize_message(&message);
                    dbg!(&serialized);
                    inner.write_all(&serialized).await?;
                    inner.flush().await?;
                    info!("Wrote ZMessage to pipe");
                    time::sleep(Duration::from_secs(1)).await;
                    
                }
                Ok(())
            });
        }
        
        Ok::<_, io::Error>(())
    });
    server.await??;
    Ok(())
    /* do something else not server related here */
}

pub fn serialize_message(message: &ZMessage) -> Vec<u8> {
    let serialized = to_vec(vec![], message).expect("Failed to serialize ZMessage");
    serialized
}