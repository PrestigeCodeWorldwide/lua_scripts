#![allow(
    unused_imports,
    unused_variables,
    unused_mut,
    dead_code,
    unreachable_code,
    non_snake_case
)]

use anyhow::anyhow;
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

pub mod np_server;
pub mod protocol;

pub type Result = anyhow::Result<()>;

const PIPE_NAME: &str = r"\\.\\pipe\\zenactorpipe";

#[tokio::main]
async fn main() -> Result {
    init_logging(tracing::Level::DEBUG)?;
    info!("Starting server");
    np_server::start_server().await?;
    Ok(())
}

fn init_logging(log_level: tracing::Level) -> anyhow::Result<()> {
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
