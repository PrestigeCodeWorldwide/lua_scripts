use simplelog::*;
use zenactor_ffi::*;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let log_config = ConfigBuilder::new()
        .set_location_level(LevelFilter::Error)
        .set_time_level(LevelFilter::Debug)
        .build();

    TermLogger::init(
        LevelFilter::Info,
        log_config,
        TerminalMode::Mixed,
        ColorChoice::Always,
    )?;

    //let rx: Rx = local::channel();

    let mut client = crate::ZenActorClient::new();

    client.init().await?;

    Ok(())
}
