#![allow(
    non_snake_case,
    unused_variables,
    unused_mut,
    unused_imports,
    dead_code
)]

use derive_more::Display;
use futures::future::err;
use futures::SinkExt;
use log::{debug, error, info, warn};
use protocol::ClientId;
use serde::{Deserialize, Serialize};
use simplelog::*;
use std::collections::HashMap;
use std::collections::VecDeque;
use std::env;
use std::io;
use std::net::SocketAddr;
use std::ops::Deref;
use std::process::id;
use std::sync::Arc;
use std::time::Duration;
use std::{clone, collections::HashSet};
use tokio::io::{AsyncBufReadExt, AsyncReadExt, AsyncWriteExt, BufReader, WriteHalf};
use tokio::net::{TcpListener, TcpStream};
use tokio::sync::{mpsc, Mutex, MutexGuard};
use tokio::time::timeout;
use tokio_stream::StreamExt;
use tokio_util::codec::{Framed, LinesCodec};
use uuid::Uuid;
type AnyResult = anyhow::Result<()>;

/// Shorthand for the transmit half of the message channel.
type Tx = mpsc::UnboundedSender<String>;

/// Shorthand for the receive half of the message channel.
type Rx = mpsc::UnboundedReceiver<String>;

#[derive(Debug, Default)]
pub struct ZenActorClient {
    pub id: Option<ClientId>,
    pub shared_state: Arc<Mutex<VecDeque<String>>>,
}

impl ZenActorClient {
    pub fn new() -> Self {
        Self {
            id: None,
            shared_state: Arc::new(Mutex::new(VecDeque::new())),
        }
    }

    pub async fn run() -> AnyResult {
        let addr = env::args()
            .nth(1)
            .unwrap_or_else(|| "127.0.0.1:8080".to_string());

        let mut stream = TcpStream::connect(addr).await?;
        let (reader_stream, mut writer_stream) = stream.into_split();
        let mut reader = BufReader::new(reader_stream);

        info!("Connected to server.");

        tokio::spawn(async move {
            loop {
                let mut response = String::new();
                match reader.read_line(&mut response).await {
                    Ok(0) => {
                        info!("Response was 0");
                        break;
                    }
                    Ok(_) => {
                        info!("Response: {}.", response);
                        // put into message queue that lua can retrieve inside of Receive()
                    }
                    Err(e) => {
                        info!("Error while reading response. Error {}", e);
                        break;
                    }
                }
            }
        });
        
        let mut input_reader = tokio::io::BufReader::new(tokio::io::stdin());
        loop {
            let mut input = String::new();
            input_reader.read_line(&mut input).await.unwrap();

            writer_stream.write_all(input.as_bytes()).await?;
            writer_stream.flush().await?;
        }

        Ok(())
    }
}
