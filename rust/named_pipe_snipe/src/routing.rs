pub mod mq {
    pub mod proto {
        pub mod routing {
            include!(concat!(env!("OUT_DIR"), "/mq.proto.routing.rs"));
        }
    }
}
