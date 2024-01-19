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
use std::{clone, collections::HashSet};
use tokio::sync::{mpsc, Mutex, MutexGuard};
use tokio::time::timeout;
use tokio::{
    io::{AsyncBufReadExt, AsyncReadExt, AsyncWriteExt, BufReader, WriteHalf},
    task::JoinHandle,
};
use tokio::{
    net::{TcpListener, TcpStream},
    try_join,
};
use tokio_stream::StreamExt;
use tokio_util::codec::{Framed, LinesCodec};
use uuid::Uuid;

use std::ffi::c_char;
use std::ffi::CString;
use std::format as f;
use std::time::{Duration, Instant};
use windows::{
    core::s,
    Win32::Foundation::*,
    Win32::{System::SystemServices::*, UI::WindowsAndMessaging::MessageBoxA},
};

/////////// TYPES
type DWORD = u32;
type FFIStringPtr = *const c_char;
type AnyResult = anyhow::Result<()>;

// example extern
#[no_mangle]
pub extern "C" fn add_in_rust(left: u32, right: u32) -> u32 {
    left + right
}

/// Shorthand for the transmit half of the message channel.
type Tx = mpsc::UnboundedSender<String>;

/// Shorthand for the receive half of the message channel.
type Rx = mpsc::UnboundedReceiver<String>;

#[derive(Debug, Default)]
#[repr(C)]
pub struct ZenActorClient {
    pub id: Option<ClientId>,
    pub shared_state: Arc<Mutex<VecDeque<String>>>,
    writer_handle: Option<JoinHandle<()>>,
    reader_handle: Option<JoinHandle<()>>,
}

impl ZenActorClient {
    pub fn new() -> Self {
        Self {
            id: None,
            shared_state: Arc::new(Mutex::new(VecDeque::new())),
            writer_handle: None,
            reader_handle: None,
        }
    }

    pub async fn run(&mut self) -> AnyResult {
        let handles = try_join!(
            self.reader_handle.take().unwrap(),
            self.writer_handle.take().unwrap()
        )?;

        Ok(())
    }

    pub async fn get_messages(&mut self) -> VecDeque<String> {
        let mut messages: VecDeque<String> = VecDeque::new();

        let mut shared_state = self.shared_state.lock().await;
        messages.append(&mut shared_state.drain(..).collect::<VecDeque<String>>());

        messages
    }

    pub async fn start(&mut self) -> AnyResult {
        let addr = env::args()
            .nth(1)
            .unwrap_or_else(|| "127.0.0.1:8080".to_string());

        let mut stream = TcpStream::connect(addr).await?;
        let (reader_stream, mut writer_stream) = stream.into_split();
        let mut reader = BufReader::new(reader_stream);

        info!("Connected to server.");

        let reader_handle = tokio::spawn(async move {
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

        let writer_handle = tokio::spawn(async move {
            let mut input_reader = tokio::io::BufReader::new(tokio::io::stdin());
            loop {
                let mut input = String::new();
                match input_reader.read_line(&mut input).await {
                    Ok(_) => {
                        if let Err(e) = writer_stream.write_all(input.as_bytes()).await {
                            eprintln!("Failed to write to stream: {}", e);
                            break;
                        }
                        if let Err(e) = writer_stream.flush().await {
                            eprintln!("Failed to flush stream: {}", e);
                            break;
                        }
                    }
                    Err(e) => {
                        eprintln!("Failed to read line: {}", e);
                        break;
                    }
                }
            }
        });

        self.reader_handle = Some(reader_handle);
        self.writer_handle = Some(writer_handle);

        Ok(())
    }
}
