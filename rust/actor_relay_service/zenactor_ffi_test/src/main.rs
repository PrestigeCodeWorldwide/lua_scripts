use simplelog::*;
use zenactor_ffi::*;

fn main() -> ! {
    //let rx: Rx = local::channel();

    let mut client = crate::ZenActorClient::new("TestRoom", "TestChannel");

    client.init().unwrap();

    loop {}
}
