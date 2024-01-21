#![allow(
    non_snake_case,
    unused_variables,
    unused_mut,
    unused_imports,
    dead_code
)]

use bincode::enc::write;
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
use tokio::{
    io::{AsyncBufReadExt, AsyncReadExt, AsyncWriteExt, BufReader, WriteHalf},
    task::JoinHandle,
};
use tokio::{
    net::{TcpListener, TcpStream},
    try_join,
};
use tokio::{runtime::Handle, time::timeout};
use tokio::{
    runtime::Runtime,
    sync::{mpsc, Mutex, MutexGuard},
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
pub extern "C" fn zen_actor_client_new(room: *const c_char, channel: *const c_char) -> *mut c_void {
    let room_str = unsafe {
        assert!(!room.is_null());
        CStr::from_ptr(room).to_string_lossy().into_owned()
    };

    let channel_str = unsafe {
        assert!(!channel.is_null());
        CStr::from_ptr(channel).to_string_lossy().into_owned()
    };

    let client = Box::new(ZenActorClient::new(room_str, channel_str));
    Box::into_raw(client) as *mut c_void
}

#[no_mangle]
pub extern "C" fn zen_actor_client_step_runtime(client_ptr: *mut c_void) -> i32 {
    if client_ptr.is_null() {
        return -1;
    }

    let client = unsafe { &mut *(client_ptr as *mut ZenActorClient) };

    // which runtime should i be using here? client.runtime?

    //let mut runtime = client.runtime.take().unwrap();
    //let result = runtime.block_on(client.step_runtime());
    //client.runtime = Some(runtime);
    client.step_runtime();
    0
}

#[no_mangle]
pub extern "C" fn zen_actor_client_init(client_ptr: *mut c_void) -> *const c_char {
    if client_ptr.is_null() {
        let messages_string = format!("-1");
        let c_string = CString::new(messages_string).unwrap();
        return c_string.into_raw();
    }
    let client = unsafe { &mut *(client_ptr as *mut ZenActorClient) };

    //instead of this, lets not block in here at all and just do it in client ///////////create the runtime we want here and pass it into client.init() if we can?
    //let local_set = tokio::task::LocalSet::new();
    //let rt = tokio::runtime::Builder::new_current_thread()
    //    .enable_all()
    //    .build()
    //    .unwrap();

    //let rt_clone = rt.

    //let result = rt.block_on(local_set.run_until(client.init()));

    //match result {
    //    Ok(res) => CString::new(res.to_owned()).unwrap().into_raw(), // return null pointer if there's no error
    //    Err(e) => {
    //        let c_string = CString::new(e.to_string()).unwrap();
    //        c_string.into_raw() // convert the CString into a raw pointer
    //    }
    //}
    let mut runtime = client.runtime.as_mut().unwrap().handle().clone();

    let res: String = match runtime.block_on(client.init()) {
        Ok(_) => "SuccessfulClientInit".to_string(),
        Err(e) => e.to_string(),
    };

    //let res = 0;

    let messages_string = format!("{}", &res);
    let c_string = CString::new(messages_string).unwrap();
    c_string.into_raw()
}

#[no_mangle]
pub extern "C" fn zen_actor_client_interact(client_ptr: *mut c_void) -> *mut c_char  I AM TIRED BUT IM RIPPING OUT ALL THE assert(clientptrs are null) {
    if client_ptr.is_null() {
        let messages_string = format!("-1");
        let c_string = CString::new(messages_string).unwrap();
        return c_string.into_raw();
    }
	
	let client = unsafe {
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
pub extern "C" fn zen_actor_client_get_rust_logs(client_ptr: *mut c_void) -> *mut c_char {
    let client = unsafe {
        assert!(!client_ptr.is_null());
        &mut *(client_ptr as *mut ZenActorClient)
    };

    let messages = tokio::runtime::Runtime::new()
        .unwrap()
        .block_on(client.get_rust_logs());

    // Convert messages to a format that can be returned via FFI
    let big_string: String = messages.into_iter().collect();
    let messages_string = format!("{:?}", big_string);
    let c_string = CString::new(messages_string).unwrap();
    c_string.into_raw()
}

#[no_mangle]
pub extern "C" fn zen_actor_client_send_message(
    client_ptr: *mut c_void,
    message: FFIStringPtr,
) -> *mut c_char {
    info!("zen_actor_client_send_message");
    // Ensure the client pointer is not null
    if client_ptr.is_null() {
        let res_string = format!("CLIENT_IS_NULL");
        let c_string = CString::new(res_string).unwrap();
        return c_string.into_raw();
    }

    // Convert the message to a Rust string
    let c_str = unsafe { CStr::from_ptr(message) };
    let message_str = match c_str.to_str() {
        Ok(s) => {
            let res_string = format!("{}", s);
            res_string
        }
        Err(e) => {
            let error_string = format!("{}", e);
            error_string
        }
    };

    // Call send_message on the client
    let client = unsafe { &mut *(client_ptr as *mut ZenActorClient) };
    let result = tokio::runtime::Runtime::new()
        .unwrap()
        .block_on(client.send_message(message_str.to_string()));

    match result {
        Ok(_) => {
            let res_string = format!("SUCCESS");
            let c_string = CString::new(res_string).unwrap();
            c_string.into_raw()
        }
        Err(e) => {
            let error_string = format!("{}", e);
            let c_string = CString::new(error_string).unwrap();
            c_string.into_raw()
        }
    }

    //match result {
    //    Ok(_) => 0,
    //    Err(e) => -3,
    //}
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

async fn write_rust_log(message_queue: &mut Arc<Mutex<VecDeque<String>>>, message: String) {
    let mut message_queue = message_queue.lock().await;
    message_queue.push_back(message.to_owned());
}

#[derive(Debug, Default)]
#[repr(C)]
pub struct ZenActorClient {
    pub id: Option<ClientId>,
    pub server_message_queue: Arc<Mutex<VecDeque<String>>>,
    pub client_message_queue: Arc<Mutex<VecDeque<String>>>,
    pub rust_log_messages: Arc<Mutex<VecDeque<String>>>,
    runtime: Option<Runtime>,
    local_set: tokio::task::LocalSet,
    pub room: String,
    pub channel: String,
    //writer_handle: Option<JoinHandle<()>>,
    //reader_handle: Option<JoinHandle<()>>,
}

impl ZenActorClient {
    pub fn new(room_to_connect: String, channel_to_connect: String) -> Self {
        let starter_messages = vec!["hello".to_string(), "world".to_string()];
        let starter_messages: VecDeque<String> = starter_messages.into_iter().collect();

        let myRuntime = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();

        Self {
            id: None,
            server_message_queue: Arc::new(Mutex::new(starter_messages)),
            //writer_handle: None,
            //reader_handle: None,
            client_message_queue: Arc::new(Mutex::new(VecDeque::new())),
            rust_log_messages: Arc::new(Mutex::new(VecDeque::new())),
            runtime: Some(myRuntime),
            local_set: tokio::task::LocalSet::new(),
            room: room_to_connect,
            channel: channel_to_connect,
        }
    }

    pub fn step_runtime(&mut self) {
        self.runtime.as_mut().unwrap().spawn_blocking(|| {
            tokio::runtime::Builder::new_current_thread()
                .enable_all()
                .build()
                .unwrap()
                .block_on(async {
                    tokio::task::yield_now().await;
                });
        });
        //let mut runtime = self.runtime.clone().unwrap();
        //runtime.block_on(async {
        //    tokio::task::yield_now().await;
        //});
    }

    //pub async fn run(&mut self) -> AnyResult {
    //    let handles = try_join!(
    //        self.reader_handle.take().unwrap(),
    //        self.writer_handle.take().unwrap()
    //    )?;

    //    Ok(())
    //}

    pub async fn get_rust_logs(&mut self) -> VecDeque<String> {
        let mut messages: VecDeque<String> = VecDeque::new();

        let mut shared_state = self.rust_log_messages.lock().await;
        //messages.append(&mut shared_state.drain(..).collect::<VecDeque<String>>());
        messages.append(&mut shared_state.drain(..).collect());
        //messages.push_back("Test message".to_owned());

        messages
    }

    //async fn write_rust_log(&mut self, message: String) {
    //    let mut message_queue = self.rust_log_messages.lock().await;
    //    message_queue.push_back(message.to_owned());
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
        write_rust_log(
            &mut self.rust_log_messages,
            f!("Sending message: {message}"),
        )
        .await;
        message_queue.push_back(message);
        Ok(())
    }

    pub async fn init(&mut self) -> anyhow::Result<String> {
        let addr: SocketAddr = "127.0.0.1:8080".parse()?;

        let mut stream = TcpStream::connect(addr).await?;
        let (reader_stream, mut writer_stream) = stream.into_split();
        let mut reader = BufReader::new(reader_stream);

        write_rust_log(
            &mut self.rust_log_messages,
            "Connected to server.".to_owned(),
        )
        .await;
        let shared_state = Arc::clone(&self.server_message_queue);
        let mut log_writer = Arc::clone(&self.rust_log_messages); // assuming write_rust_log is clonable
        write_rust_log(
            &mut self.rust_log_messages,
            "Starting reader thread.".to_owned(),
        )
        .await;

        let runtime = self.runtime.as_mut().unwrap().handle().clone();

        runtime.spawn(async move {
            //let mut loop_writer = log_writer.clone();
            write_rust_log(&mut log_writer, "In Reader Thread".to_owned()).await;

            loop {
                let mut response = String::new();
                match tokio::time::timeout(
                    Duration::from_secs(5), // Set a timeout of 5 seconds
                    reader.read_line(&mut response),
                )
                .await
                {
                    Ok(Ok(0)) => {
                        write_rust_log(&mut log_writer, "Response was 0".to_owned()).await;
                        //break;
                    }
                    Ok(Ok(_)) => {
                        let res = format!("Response: {}.", response);

                        write_rust_log(&mut log_writer, res).await;

                        // put into message queue that lua can retrieve inside of Receive()
                        let mut shared_state = shared_state.lock().await;
                        shared_state.push_back(response);
                        //break;
                    }
                    Ok(Err(e)) => {
                        let res = format!("Error while reading response. Error {}", e);

                        write_rust_log(&mut log_writer, res).await;
                        //break;
                    }
                    Err(_) => {
                        let res = format!("Timeout while reading response.");

                        write_rust_log(&mut log_writer, res).await;
                        //break;
                    }
                }
                // Yield control back to the Tokio scheduler
                tokio::task::yield_now().await;
            }

            //loop {
            //    let mut response = String::new();
            //    match reader.read_line(&mut response).await {
            //        Ok(0) => {
            //            write_rust_log(loop_writer, "Response was 0".to_owned()).await;
            //            break;
            //        }
            //        Ok(_) => {
            //            let res = format!("Response: {}.", response);

            //            write_rust_log(loop_writer, res).await;

            //            // put into message queue that lua can retrieve inside of Receive()
            //            let mut shared_state = shared_state.lock().await;
            //            shared_state.push_back(response);
            //            break;
            //        }
            //        Err(e) => {
            //            let res = format!("Error while reading response. Error {}", e);

            //            write_rust_log(loop_writer, res).await;
            //            break;
            //        }
            //    }
            //    // Yield control back to the Tokio scheduler

            //}
            //tokio::task::yield_now().await;
        });

        //let mut client_queue = self.client_message_queue.clone();
        //let log_writer = Arc::clone(&self.rust_log_messages);
        //write_rust_log(
        //    self.rust_log_messages.clone(),
        //    "Starting writer thread.".to_owned(),
        //)
        //.await;
        //tokio::spawn(async move {
        //    loop {
        //        let mut message_queue = client_queue.lock().await;
        //        if let Some(message) = message_queue.pop_front() {
        //            if let Err(e) = writer_stream.write_all(message.as_bytes()).await {
        //                let res = format!("Failed to write to stream: {}", e);
        //                write_rust_log(log_writer, res).await;
        //                break;
        //            }
        //            if let Err(e) = writer_stream.flush().await {
        //                let res = format!("Failed to flush stream: {}", e);
        //                write_rust_log(log_writer, res).await;
        //                break;
        //            }
        //        }
        //    }
        //});

        Ok("Init Success".to_string())
    }
}
