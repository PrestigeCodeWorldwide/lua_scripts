#![allow(
    non_snake_case,
    unused_variables,
    unused_mut,
    unused_imports,
    dead_code
)]

use bincode::enc::write;
use crossbeam::queue::SegQueue;
use derive_more::Display;
use futures::future::err;
use futures::SinkExt;
use log::{debug, error, info, warn};
use protocol::{ClientId, ServerOperation};
use serde::{Deserialize, Serialize};
use simplelog::*;
use std::fs::File;
use std::io;
use std::io::prelude::*;
use std::net::SocketAddr;
use std::net::TcpStream;
use std::ops::Deref;
use std::os::raw::c_void;
use std::process::id;
use std::sync::Arc;
use std::{borrow::BorrowMut, collections::VecDeque};
use std::{clone, collections::HashSet};
use std::{collections::HashMap, ffi::CStr};
use std::{env, sync::Mutex, thread};

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

#[no_mangle]
pub extern "C" fn zen_actor_client_new(room: *const c_char, channel: *const c_char) -> *mut c_void {
    let room_str = unsafe {
        if room.is_null() {
            CString::new("NULL ROOM").unwrap()
        } else {
            CStr::from_ptr(room).to_owned()
        }
    };

    let channel_str = unsafe {
        if channel.is_null() {
            CString::new("NULL CHANNEL").unwrap()
        } else {
            CStr::from_ptr(channel).to_owned()
        }
    };

    let client = Box::new(ZenActorClient::new(
        room_str.to_string_lossy().into_owned(),
        channel_str.to_string_lossy().into_owned(),
    ));
    Box::into_raw(client) as *mut c_void
}

// maybe unneeded with swap to threads
//#[no_mangle]
//pub extern "C" fn zen_actor_client_step_runtime(client_ptr: *mut c_void) -> i32 {
//    if client_ptr.is_null() {
//        warn!("client ptr is null!");
//        return -1;
//    }
//    let client = unsafe { &mut *(client_ptr as *mut ZenActorClient) };
//    let result = client
//        .runtime
//        .block_on(async { client.step_runtime().await });

//    match result {
//        Ok(_) => 0,
//        Err(_) => -2,
//    }
//}

#[no_mangle]
pub extern "C" fn zen_actor_client_init(client_ptr: *mut c_void) -> *const c_char {
    if client_ptr.is_null() {
        let messages_string = CString::new("-1").unwrap();
        return messages_string.into_raw();
    }
    let client = unsafe { &mut *(client_ptr as *mut ZenActorClient) };

    let messages_string = format!("SUCCESS");
    let c_string = CString::new(messages_string).unwrap();
    c_string.into_raw()
}

/*
#[no_mangle]
pub extern "C" fn zen_actor_client_interact(client_ptr: *mut c_void) -> *mut c_char {
    if client_ptr.is_null() {
        let messages_string = format!("-1");
        let c_string = CString::new(messages_string).unwrap();
        return c_string.into_raw();
    }

    let client = unsafe { &mut *(client_ptr as *mut ZenActorClient) };
    let messages_string = format!("SUCCESS");
    let c_string = CString::new(messages_string).unwrap();
    c_string.into_raw()
}

#[no_mangle]
pub extern "C" fn zen_actor_client_get_messages_sync(client_ptr: *mut c_void) -> *mut c_char {
    if client_ptr.is_null() {
        let messages_string = format!("Client ptr is null");
        let c_string = CString::new(messages_string).unwrap();
        return c_string.into_raw();
    }
    let client = unsafe { &mut *(client_ptr as *mut ZenActorClient) };

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
    if client_ptr.is_null() {
        let messages_string = format!("Client ptr is null");
        let c_string = CString::new(messages_string).unwrap();
        return c_string.into_raw();
    }
    let client = unsafe { &mut *(client_ptr as *mut ZenActorClient) };

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
    info!("in FFI zen_actor_client_send_message");
    // Ensure the client pointer is not null
    if client_ptr.is_null() {
        error!("Client pointer was null in FFI send_message");
        let res_string = format!("CLIENT_IS_NULL");
        let c_string = CString::new(res_string).unwrap();
        return c_string.into_raw();
    }

    // Convert the message to a Rust string
    let c_str = unsafe { CStr::from_ptr(message) };
    info!("Got CStr from Lua: {} ", c_str.to_string_lossy());
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
*/
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
//pub type Tx = crossbeam::mpsc::UnboundedSender<String>;

/// Shorthand for the receive half of the message channel.
//pub type Rx = mpsc::UnboundedReceiver<String>;

//async fn write_rust_log(message_queue: &mut Arc<Mutex<VecDeque<String>>>, message: String) {
//    let mut message_queue = message_queue.lock().await;
//    message_queue.push_back(message.to_owned());
//}

#[derive(Debug, Default, Clone)]
#[repr(C)]
pub struct ZenActorClient {
    pub id: Option<ClientId>,
    //pub server_message_queue: Arc<Mutex<VecDeque<String>>>,
    pub server_message_queue: Arc<SegQueue<String>>,
    pub client_message_queue: Arc<SegQueue<String>>,
    //pub rust_log_messages: Arc<Mutex<VecDeque<String>>>,
    //runtime: Arc<Mutex<Option<Runtime>>>,
    //local_set: tokio::task::LocalSet,
    pub room: String,
    pub channel: String,
    //writer_handle: Option<JoinHandle<()>>,
    //reader_handle: Option<JoinHandle<()>>,
}

impl ZenActorClient {
    // maybe not even needed anymore when swapping to threads instead of tokio
    //pub async fn step_runtime(&self) -> Result<(), Box<dyn std::error::Error>> {
    //    let runtime = self.runtime.lock().await;
    //    if let Some(rt) = &*runtime {
    //        rt.spawn(async {
    //            tokio::task::yield_now().await;
    //        });
    //    }
    //    Ok(())
    //}

    pub fn new<T: AsRef<str>>(room_to_connect: T, channel_to_connect: T) -> Self {
        // init logging
        let log_config = ConfigBuilder::new()
            .set_location_level(LevelFilter::Error)
            .set_time_level(LevelFilter::Error)
            .build();

        //WriteLogger::init(
        //    LevelFilter::Info,
        //    log_config,
        //    File::create("c:\\temp\\ZenActorClient.log").unwrap(),
        //)
        //.unwrap();

        let _ = CombinedLogger::init(vec![
            TermLogger::new(
                LevelFilter::Info,
                log_config.clone(),
                TerminalMode::Mixed,
                ColorChoice::Auto,
            ),
            WriteLogger::new(
                LevelFilter::Info,
                log_config.clone(),
                File::create("c:\\temp\\ZenActorClient.log").unwrap(),
            ),
        ]);

        let starter_messages = vec!["hello".to_string(), "world".to_string()];
        let starter_messages_queue: SegQueue<String> = SegQueue::new();
        starter_messages_queue.push("Hello".to_owned());
        starter_messages_queue.push("World".to_owned());
        //let starter_messages: SegQueue<String> = starter_messages.into_iter().collect();

        //let myRuntime = tokio::runtime::Builder::new_current_thread()
        //    .enable_all()
        //    .build()
        //    .unwrap();

        Self {
            id: None,
            server_message_queue: Arc::new(starter_messages_queue),
            client_message_queue: Arc::new(SegQueue::new()),
            //rust_log_messages: Arc::new(Mutex::new(VecDeque::new())),
            //runtime: Arc::new(Mutex::new(Some(myRuntime))),
            room: room_to_connect.as_ref().to_owned(),
            channel: channel_to_connect.as_ref().to_owned(),
        }
    }

    pub fn init(&mut self) -> anyhow::Result<String> {
        info!("In init function");
        let addr: SocketAddr = "127.0.0.1:8080".parse()?;

        let mut stream = TcpStream::connect(addr).expect("Couldn't connect to server!");
        stream
            .set_read_timeout(Some(Duration::new(3, 0)))
            .expect("Couldn't set read timeout");
        stream
            .set_write_timeout(Some(Duration::new(3, 0)))
            .expect("Couldn't set write timeout");

        info!("Connected to server");
        let shared_state = Arc::clone(&self.server_message_queue);
        
        info!("Spawning reader thread");
        let mut input_stream = stream.try_clone().unwrap();

        let reader_thread = std::thread::spawn(move || -> AnyResult {
            info!("Inside reader thread");

            loop {
                //let mut client_buffer = String::new();
                let mut client_buffer = [0u8; 1024];
                let res = match input_stream.read(&mut client_buffer) {
                    Ok(n) => {
                        if n == 0 {
                            info!("Read 0, connection closed by peer");
                            // TODO: Fix this so that it attempts to reconnect from outside the loop
                            break; // Exit the loop if the connection has been closed
                        } else {
                            info!("Read {} bytes", n);
                            let msg_slice = &client_buffer[..n]; // Slice the buffer up to the number of bytes read
                            let msg_string = std::str::from_utf8(msg_slice).unwrap(); // Convert only the received bytes to a string

                            // Perform JSON deserialization on the correctly sliced string
                            let result: Result<ServerOperation, _> =
                                serde_json::from_str(msg_string);
                            match result? {
                                ServerOperation::ClientConnectApproved(msg) => {
                                    self.id = Some(ClientId(msg.0));
                                },
                                ServerOperation::Disconnect => todo!(),
                                ServerOperation::Message { room, channel, message } => {
                                    info!("Received server message {}", message);
                                    
                                },                               
                            }
                        }
                    }
                    Err(ref e) if e.kind() == std::io::ErrorKind::WouldBlock => {
                        // Handle the case where the non-blocking read would block (timed out)
                        info!("Read timed out, no data available");
                    }
                    Err(e) => {
                        // Handle other read errors
                        //error!("Failed to read from socket: {}", e);
                    }
                };
                std::thread::sleep(std::time::Duration::from_millis(1000));
            }
            Ok(())
        });
        info!("Finished spawning reader thread");

        let mut output_stream = stream.try_clone().unwrap();
        
        

        let writer_thread = thread::spawn(move || {
            //let mut loop_writer = log_writer.clone();
            info!("Inside Writer thread");

            //let output_stream = &mut stream;

            loop {
                //io::stdin().read_line(&mut user_buffer).unwrap();
                let user_buffer = String::from("{\"TestKey\":\"Test Value\"}\n");

                output_stream.write(user_buffer.as_bytes()).unwrap();
                output_stream.flush().unwrap();
                info!("Inside Writer loop! Sleeping for 1s: {} ", &user_buffer);
                std::thread::sleep(std::time::Duration::from_millis(5000));
            }

            //let mut response = String::new();
            //let mut count = 0;
            //loop {
            //    // shared_state.push_back the result from timeout(reader.read_line(&mut response))
            //    count += 1;
            //    info!("Inside Writer loop! Sleeping for 1s. Count: {}", &count);
            //    std::thread::sleep(std::time::Duration::from_millis(900));
            //}
        });

        Ok("Init Success".to_string())
    }

    //pub async fn get_rust_logs(&mut self) -> VecDeque<String> {
    //    let mut messages: VecDeque<String> = VecDeque::new();

    //    let mut shared_state = self.rust_log_messages.lock().await;
    //    messages.append(&mut shared_state.drain(..).collect());

    //    messages
    //}

    //pub fn get_messages(&mut self) -> VecDeque<String> {
    //    let mut messages: VecDeque<String> = VecDeque::new();

    //    let mut shared_state = self.server_message_queue.lock().await;
    //    //messages.append(&mut shared_state.drain(..).collect::<VecDeque<String>>());
    //    messages.append(&mut shared_state.drain(..).collect());
    //    //messages.push_back("Test message".to_owned());

    //    messages
    //}

    //pub fn send_message(&mut self, message: String) -> AnyResult {
    //    info!("In client.send_message which really only adds a message to queue");
    //    let mut message_queue = self.client_message_queue.lock().await;
    //    write_rust_log(
    //        &mut self.rust_log_messages,
    //        f!("Sending message: {message}"),
    //    )
    //    .await;
    //    message_queue.push_back(message);
    //    Ok(())
    //}
}
