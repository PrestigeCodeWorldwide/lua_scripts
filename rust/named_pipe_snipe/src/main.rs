#![allow(
    unused_imports,
    unused_variables,
    unused_mut,
    dead_code,
    unreachable_code,
    non_snake_case
)]

use anyhow::anyhow;
use bincode::{self, de};
use log::debug;
use prost::Message;
use std::time::Duration;
use std::{
    fs::OpenOptions,
    io::{self, Write},
};
use tokio::io::AsyncReadExt;
use tokio::io::Interest;
use tokio::net::windows::named_pipe::ClientOptions;
use tokio::time;
use tracing::{error, info, warn};
use tracing_appender::non_blocking::WorkerGuard;
use tracing_appender::rolling::{RollingFileAppender, Rotation};
use tracing_subscriber::fmt::Subscriber;
use tracing_subscriber::layer::Layered;
use tracing_subscriber::{
    fmt::{self, MakeWriter},
    FmtSubscriber,
};
use windows_sys::Win32::Foundation::ERROR_PIPE_BUSY;

pub mod routing;
pub mod np_server;

use crate::{
    routing::mq::proto::routing::*,
};

pub mod protocol;

pub type Result = anyhow::Result<()>;

const PIPE_NAME: &str = r"\\.\\pipe\\zenactorpipe";

#[tokio::main]
async fn main() -> Result {
    //load_protobuf().await?;
    init_logging(tracing::Level::DEBUG)?;
    //main_named_pipe_loop().await?;
    info!("Starting server");
    np_server::start_server().await?;
    Ok(())
}

async fn load_protobuf() -> Result {
    let mut address = Address::default();
    address.account = Some("account".to_string());
    println!("Address account is: {}", address.account.unwrap());
    Ok(())
}

//async fn main_named_pipe_loop() -> Result {
    
//    info!("Starting named pipe client");
//    let mut client = loop {
//        match ClientOptions::new().open(PIPE_NAME) {
//            Ok(client) => break client,
//            Err(e) if e.raw_os_error() == Some(ERROR_PIPE_BUSY as i32) => (),
//            Err(e) => {
//                println!("FUK");
//                return Err(anyhow::Error::new(e));
//            }
//        }

//        time::sleep(Duration::from_millis(50)).await;
//    };

//    let client_info = client.info()?;
//    let mut ctr = 0;

//    loop {
//        ctr += 1;
//        let ready = client
//            .ready(Interest::READABLE | Interest::WRITABLE)
//            .await?;

//        if ready.is_readable() {
//            let mut data = vec![0; 1024];

//            let mut header_bytes = [0u8; 16]; // MQMessageHeader size
//            client.read_exact(&mut header_bytes).await?;
//            let header = MQMessageHeader::from_bytes(&header_bytes);

//            dbg!(&header);

//            let mut message_bytes = vec![0u8; header.message_length as usize];

//            match header.message_id {
//                MQMessageId::MsgNull => {
//                    debug!("Received MsgNull acknowledgement");
//                }
//                MQMessageId::MsgEcho => {
//                    debug!("Received MsgEcho");
//                }
//                MQMessageId::MsgRoute => {
//                    debug!("Received MsgRoute");
//                    client.read_exact(&mut message_bytes).await?;
//                    dbg!(&message_bytes);
//                    // Now you can deserialize your protobuf message from message_bytes
//                    // For example, if the message is an Envelope:
//                    match Envelope::decode(&*message_bytes) {
//                        Ok(envelope) => {
//                            dbg!(envelope);
//                        }
//                        Err(e) => {
//                            info!("Failed to decode envelope");
//                            dbg!(e);
//                        }
//                        // Handle the deserialized envelope
//                        //info!("Got an envelope successfully!");
//                        //dbg!(envelope);
//                    };
//                }
//                MQMessageId::MsgIdentification => {
//                    debug!("Received MsgIdentification ");
//                }
//                MQMessageId::MsgDropped => {
//                    debug!("Received MsgDropped ");
//                }
//                MQMessageId::MsgMainProcessLoaded => {
//                    debug!("Received MsgMainProcessLoaded");
//                }
//                MQMessageId::MsgMainProcessUnloaded => {
//                    debug!("Received MsgMainProcessUnloaded");
//                }
//                MQMessageId::MsgMainCrashpadConfig => {
//                    debug!("Received MsgMainCrashpadConfig");
//                }
//                MQMessageId::MsgMainReqUnload => {
//                    debug!("Received MsgMainReqUnload");
//                }
//                MQMessageId::MsgMainFocusRequest => {
//                    debug!("Received MsgMainFocusRequest");
//                }
//                MQMessageId::MsgMainFocusActivateWnd => {
//                    debug!("Received MsgMainFocusActivateWnd");
//                }
//                MQMessageId::MsgMainReqForceunload => {
//                    debug!("Received MsgMainReqForceunload");
//                }
//            }
            
//            //match client.try_read(&mut data) {
//            //    Ok(n) => {
//            //        println!("read {} bytes", n);
//            //        if n == 0 {
//            //            //connection closed by peer
//            //            warn!("Connection closed by peer, exiting read loop");
//            //            break;
//            //        }

//            //        // Trim the buffer to the actual size read
//            //        data.truncate(n);
//            //        dbg!(&data);

//            //        let header = MQMessageHeader::from_bytes(&data);
//            //        dbg!(&header);
//            //        let mut message_bytes = vec![0u8; header.message_length as usize];

//            //        // Attempt to deserialize the protobufdata
//            //        let envelope = deserialize_envelope(&data[16..])?;
//            //        info!(
//            //            "mailbox: {}",
//            //            envelope.address.as_ref().ok_or("No Address")
//            //                .and_then(|addr| addr.mailbox.as_ref().ok_or("No Mailbox"))
//            //                .unwrap_or(&"Deserialize error".to_string())

//            //        );
//            //    }
//            //    Err(e) if e.kind() == io::ErrorKind::WouldBlock => {
//            //        continue;
//            //    }
//            //    Err(e) => {
//            //        return Err(e.into());
//            //    }
//            //}
//        }

//        //if ready.is_writable() {
//        //    // Try to write data, this may still fail with `WouldBlock`
//        //    // if the readiness event is a false positive.
//        //    time::sleep(Duration::from_millis(1000)).await;
//        //    match client.try_write(b"hello world") {
//        //        Ok(n) => {
//        //            println!("{} write {} bytes", ctr, n);
//        //        }
//        //        Err(e) if e.kind() == io::ErrorKind::WouldBlock => {
//        //            continue;
//        //        }
//        //        Err(e) => {
//        //            return Err(e.into());
//        //        }
//        //    }
//        //}
//    }

//    Ok(())
//}

struct FlushingWriter<W: Write> {
    inner: W,
}

impl<W: Write> Write for FlushingWriter<W> {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        let count = self.inner.write(buf)?;
        self.inner.flush()?;
        Ok(count)
    }

    fn flush(&mut self) -> std::io::Result<()> {
        self.inner.flush()
    }
}

struct DualWriter<W: Write, T: Write> {
    writer1: W,
    writer2: T,
}

impl<W: Write, T: Write> Write for DualWriter<W, T> {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        let count = self.writer1.write(buf)?;
        self.writer2.write_all(&buf[..count])?;
        Ok(count)
    }

    fn flush(&mut self) -> std::io::Result<()> {
        self.writer1.flush()?;
        self.writer2.flush()
    }
}

fn init_logging(log_level: tracing::Level) -> anyhow::Result<()> {
    let mut file = OpenOptions::new()
        .write(true)
        .append(true)
        .create(true)
        .open("./named_pipe_snipe.log")?;
    
    writeln!(file, "\n--- New Log Session ---\n")?;

    
    let make_writer = move || {
        let stdout = std::io::stdout();
        let stdout_lock = stdout.lock();
        DualWriter {
            writer1: file.try_clone().expect("Failed to clone file handle"),
            writer2: stdout_lock,
        }
    };
    
    let subscriber = fmt::Subscriber::builder()
        .with_max_level(log_level)
        .with_writer(make_writer)
        .with_ansi(false)
        .compact()
        .with_file(true)
        .with_line_number(true)
        .with_thread_ids(true)
        .with_target(false)
        .without_time()
        .finish();
    
    tracing::subscriber::set_global_default(subscriber)?;
    
    Ok(())
}

//let vec_of_strings: Vec<String> = vec![
//    "first".to_string(),
//    "second".to_string(),
//    "third".to_string(),
//];

//match vec_of_strings.as_slice() {
//    [first, second, third] if first.eq("first") && second.eq("second") => {
//        println!("Matched 'first', 'second', and another element: {}", third);
//    }
//    [first, second, third] => {
//        println!("Matched three elements: {}, {}, {}", first, second, third);
//    }
//    _ => {
//        println!("This pattern matches any other number of elements.");
//    }
//}

/*
[src\main.rs:98:21] &data = [
    0, // protoVersion
    0, // MQRequest mode
    0, // status
    0, // placeholder
    1, // sequence ID
    0, // sequence ID
    0, // sequence ID
    0, // sequence ID
    234, // MQMessageId
    3, // MQMessageId
    0, // placeholder
    0, // placeholder
    41, // messageLength
    0, // messageLength
    0, // messageLength
    0, // messageLength
    92,
    92,
    46,
    92,
    112,
    105,
    112,
    101,
    92,
    99,
    114,
    97,
    115,
    104,
    112,
    97,
    100,
    95,
    50,
    53,
    52,
    57,
    50,
    95,
    82,
    71,
    88,
    72,
    88,
    73,
    85,
    75,
    75,
    86,
    88,
    71,
    80,
    75,
    75,
    89,
    0,
]

*/
