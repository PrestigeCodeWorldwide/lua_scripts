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
use std::collections::VecDeque;
use std::env;
use std::io;
use std::net::SocketAddr;
use std::ops::Deref;
use std::os::raw::c_void;
use std::process::id;
use std::sync::Arc;
use std::{clone, collections::HashSet};
use std::{collections::HashMap, ffi::CStr};
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
pub type DWORD = u32;
pub type FFIStringPtr = *const c_char;
pub type AnyResult = anyhow::Result<()>;

// example extern
#[no_mangle]
pub extern "C" fn add_in_rust(left: u32, right: u32) -> u32 {
    left + right
}

#[no_mangle]
pub extern "C" fn zen_actor_client_new() -> *mut c_void {
    let client = Box::new(ZenActorClient::new());
    Box::into_raw(client) as *mut c_void
}

//#[no_mangle]
//pub extern "C" fn zen_actor_client_run(client_ptr: *mut c_void) -> i32 {
//    let client = unsafe {
//        assert!(!client_ptr.is_null());
//        &mut *(client_ptr as *mut ZenActorClient)
//    };

//    let result = tokio::runtime::Runtime::new()
//        .unwrap()
//        .block_on(client.run());

//    match result {
//        Ok(_) => 0,
//        Err(_) => -1,
//    }
//}

#[no_mangle]
pub extern "C" fn zen_actor_client_init(client_ptr: *mut c_void) -> *const c_char {
    let client = unsafe {
        assert!(!client_ptr.is_null());
        &mut *(client_ptr as *mut ZenActorClient)
    };

    //let result = tokio::runtime::Runtime::new()
    //    .unwrap()
    //    .block_on(client.init());

    let local_set = tokio::task::LocalSet::new();
    let rt = tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .unwrap();

    let result = rt.block_on(local_set.run_until(client.init()));

    match result {
        Ok(res) => CString::new(res.to_owned()).unwrap().into_raw(), // return null pointer if there's no error
        Err(e) => {
            let c_string = CString::new(e.to_string()).unwrap();
            c_string.into_raw() // convert the CString into a raw pointer
        }
    }
}

#[no_mangle]
pub extern "C" fn zen_actor_client_interact(client_ptr: *mut c_void) {
    let client = unsafe {
        assert!(!client_ptr.is_null());
        &mut *(client_ptr as *mut ZenActorClient)
    };
    // Interact with the client here...
}

#[no_mangle]
pub extern "C" fn zen_actor_client_get_messages_sync(client_ptr: *mut c_void) -> *mut c_char {
    let client = unsafe {
        assert!(!client_ptr.is_null());
        &mut *(client_ptr as *mut ZenActorClient)
    };

    let messages = tokio::runtime::Runtime::new()
        .unwrap()
        .block_on(client.get_messages());

    // Convert messages to a format that can be returned via FFI
    let messages_string = format!("{:?}", messages);
    let c_string = CString::new(messages_string).unwrap();
    c_string.into_raw()
}

#[no_mangle]
pub extern "C" fn zen_actor_client_send_message(
    client_ptr: *mut c_void,
    message: FFIStringPtr,
) -> i32 {
    info!("zen_actor_client_send_message");
    // Ensure the client pointer is not null
    if client_ptr.is_null() {
        return -1;
    }

    // Convert the message to a Rust string
    let c_str = unsafe { CStr::from_ptr(message) };
    let message_str = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => return -2,
    };

    // Call send_message on the client
    let client = unsafe { &mut *(client_ptr as *mut ZenActorClient) };
    let result = tokio::runtime::Runtime::new()
        .unwrap()
        .block_on(client.send_message(message_str.to_string()));

    match result {
        Ok(_) => 0,
        Err(_) => -3,
    }
}

#[no_mangle]
pub extern "C" fn zen_actor_client_free(client_ptr: *mut c_void) {
    if client_ptr.is_null() {
        return;
    }
    // probably not safe: takes a raw pointer, checks if it's null, and if it's not,
    // converts it back into a box, which will be dropped (and thus deallocated) when the function ends.
    unsafe {
        let _ = Box::from_raw(client_ptr as *mut ZenActorClient);
    }
}

/// Shorthand for the transmit half of the message channel.
pub type Tx = mpsc::UnboundedSender<String>;

/// Shorthand for the receive half of the message channel.
pub type Rx = mpsc::UnboundedReceiver<String>;

#[derive(Debug, Default)]
#[repr(C)]
pub struct ZenActorClient {
    pub id: Option<ClientId>,
    pub server_message_queue: Arc<Mutex<VecDeque<String>>>,
    pub client_message_queue: Arc<Mutex<VecDeque<String>>>,
    //writer_handle: Option<JoinHandle<()>>,
    //reader_handle: Option<JoinHandle<()>>,
}

impl ZenActorClient {
    pub fn new() -> Self {
        let starter_messages = vec!["hello".to_string(), "world".to_string()];
        let starter_messages: VecDeque<String> = starter_messages.into_iter().collect();
        Self {
            id: None,
            server_message_queue: Arc::new(Mutex::new(starter_messages)),
            //writer_handle: None,
            //reader_handle: None,
            client_message_queue: Arc::new(Mutex::new(VecDeque::new())),
        }
    }

    //pub async fn run(&mut self) -> AnyResult {
    //    let handles = try_join!(
    //        self.reader_handle.take().unwrap(),
    //        self.writer_handle.take().unwrap()
    //    )?;

    //    Ok(())
    //}

    pub async fn get_messages(&mut self) -> VecDeque<String> {
        let mut messages: VecDeque<String> = VecDeque::new();

        let mut shared_state = self.server_message_queue.lock().await;
        //messages.append(&mut shared_state.drain(..).collect::<VecDeque<String>>());
        messages.append(&mut shared_state.drain(..).collect());
        //messages.push_back("Test message".to_owned());

        messages
    }

    pub async fn send_message(&mut self, message: String) -> AnyResult {
        let mut message_queue = self.client_message_queue.lock().await;
        message_queue.push_back(message);
        Ok(())
    }

    pub async fn init(&mut self) -> anyhow::Result<String> {
        let addr: SocketAddr = "127.0.0.1:8080".parse()?;

        let mut stream = TcpStream::connect(addr).await?;
        //let (reader_stream, mut writer_stream) = stream.into_split();
        //let mut reader = BufReader::new(reader_stream);

        //info!("Connected to server.");
        //let shared_state = Arc::clone(&self.server_message_queue);
        //tokio::spawn(async move {
        //    loop {
        //        let mut response = String::new();
        //        match reader.read_line(&mut response).await {
        //            Ok(0) => {
        //                info!("Response was 0");
        //                break;
        //            }
        //            Ok(_) => {
        //                info!("Response: {}.", response);
        //                // put into message queue that lua can retrieve inside of Receive()
        //                let mut shared_state = shared_state.lock().await;
        //                shared_state.push_back(response);
        //                break;
        //            }
        //            Err(e) => {
        //                info!("Error while reading response. Error {}", e);
        //                break;
        //            }
        //        }
        //    }
        //});

        //let mut client_queue = self.client_message_queue.clone();

        //tokio::spawn(async move {
        //    loop {
        //        let mut message_queue = client_queue.lock().await;
        //        if let Some(message) = message_queue.pop_front() {
        //            if let Err(e) = writer_stream.write_all(message.as_bytes()).await {
        //                eprintln!("Failed to write to stream: {}", e);
        //                break;
        //            }
        //            if let Err(e) = writer_stream.flush().await {
        //                eprintln!("Failed to flush stream: {}", e);
        //                break;
        //            }
        //        }
        //    }
        //});

        Ok("Init Success".to_string())
    }
}
