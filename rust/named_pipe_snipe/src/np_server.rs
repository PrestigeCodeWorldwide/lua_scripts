use serde::{Deserialize, Serialize};
//use serde_cbor::{from_slice, to_vec};
use cbor4ii::serde::{from_slice, to_vec};

use std::{
    io::{self, Write},
    time::Duration,
};
use tokio::net::windows::named_pipe::ServerOptions;
use tokio::{
    io::{AsyncReadExt, AsyncWriteExt},
    time,
};
use tracing::{debug, info, warn};

use crate::protocol::{Room, ZMessage, ZMessageType};
const PIPE_NAME: &str = r"\\.\pipe\zenactorpipe";
const MAX_CLIENTS: usize = 72;

#[derive(Debug, Deserialize, Serialize)]
struct Protocol {
    First: i32,
    Second: String,
}

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
            let _ = tokio::spawn(async move {
                info!("in client read thread reading...");
                let mut buf = vec![0u8; 4096];
                //inner.read_exact(&mut buf).await?;
                let buf_size = inner.read(&mut buf).await?;
                buf.truncate(buf_size);
                //debug!("Received: {:?}", buf);
                //debug!("Received as UTF: {:?}", String::from_utf8_lossy(&buf));
                let protocol: Protocol = from_slice(&buf).expect("Failed to deserialize CBOR");
                debug!("Received as Protocol: {:?}", protocol);

                let new_protocol = Protocol {
                    First: 2,
                    Second: "NewSecondString".to_string(),
                };

               
                
                let msg = ZMessage {
                    mode: crate::protocol::MQRequestMode::SimpleMessage,
                    sequence_id: 0,
                    message_type: ZMessageType::MsgRoomConnectionRequest(Room("biggerlib".to_string())),
                    payload: None,
                };
                let serialized = to_vec(vec![], &msg).expect("Failed to serialize ZMessage");
                dbg!(&serialized);
                inner.write_all(&serialized).await?;
                inner.flush().await?;
                info!("Wrote ZMessage to pipe");
                time::sleep(Duration::from_secs(1)).await;
                Ok::<_, io::Error>(())
            });
        }

        Ok::<_, io::Error>(())
    });
    server.await??;
    Ok(())
    /* do something else not server related here */
}
