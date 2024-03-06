use bincode;
use byteorder::{ByteOrder, LittleEndian};
use log::warn;

use serde::de::DeserializeOwned;
use serde::{Deserialize, Serialize};
use std::io::{Bytes, Cursor};


#[derive(Serialize, Deserialize, Debug, Clone)]
//#[repr(C, packed)]
pub struct ZMessage {
    pub mode: MQRequestMode,
    pub sequence_id: u32,
    pub message_type: ZMessageType,
    pub payload: Option<ZMessagePayload>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ZMessagePayload {
    pub cbor_encoded: String,    
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Channel(pub String);

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Room(pub String);

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Character(pub String);

/// A Destination contains a Room and a Channel.  
/// Rooms are semantically for all characters who will be controlled via scripts, and can be private or considered somewhat of a password
/// in the sense that you can join room "3I82h42oafj" and only those who know the room name can join.
/// Channels exist within rooms and are intended to allow multiple scripts to operate within the same room but without stepping on one another
/// thus each lua script should specify a different channel than other lua scripts 
/// An example of a room and channel might be "biggerlib" and "offtank" respectively.
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Destination {
    pub channel: Channel,
    pub recipient: Recipient,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub enum Recipient {
    Broadcast,
    Server,
    // String is the character name of the recipient
    Character(Character)
}

#[derive(Serialize, Deserialize, Debug, Clone)]
//#[repr(u16)]
pub enum ZMessageType {
    // An empty message, used for transmitting an acknowledgement response	
    MsgAck,
    // Send an echo message. Server will reply with the same payload. For testing.
    MsgEcho,
    // Route a message to a mailbox in a client
    MsgRoute(Destination),
     // Update routing information in server/client or request ID list
    MsgIdentification,
    // Notify clients that an address is no longer connected
    MsgDropped,
    // Ask to connect to specific room
    MsgRoomConnectionRequest(Room),        
}

#[derive(Serialize, Deserialize, Debug, Copy, Clone)]
#[serde(rename_all = "camelCase")]
#[repr(u8)]
pub enum MQRequestMode {
    SimpleMessage = 0,
    CallAndResponse = 1,
    MessageReply = 2,
}

impl TryFrom<u8> for MQRequestMode {
    type Error = &'static str;

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            0 => Ok(MQRequestMode::SimpleMessage),
            1 => Ok(MQRequestMode::CallAndResponse),
            2 => Ok(MQRequestMode::MessageReply),
            // Add other cases as needed
            _ => Err("Invalid value for MQRequestMode"),
        }
    }
}
