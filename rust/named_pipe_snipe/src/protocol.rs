use anyhow::{anyhow, Result};
use bincode;
use byteorder::{ByteOrder, LittleEndian};
use compact_str::CompactString;
use log::warn;

use serde::de::DeserializeOwned;
use serde::{Deserialize, Serialize};
use std::io::{Bytes, Cursor};


#[derive(Serialize, Deserialize, Debug, Clone)]
//#[repr(u16)]
pub enum ZMessageType {
    // An empty message, used for transmitting an acknowledgement response
    MsgAck,
    // Send an echo message. Server will reply with the same payload. For testing.
    MsgEcho,
    MsgKeepAlive,
    // Route a message to a mailbox in a client
    MsgRoute(Destination),
    // Update routing information in server/client or request ID list
    MsgIdentification,
    // Notify clients that an address is no longer connected
    MsgDropped,
    // Ask to connect to specific room
    MsgRoomConnectionRequest(Room),
    MsgMQCommandString,
}

#[derive(Serialize, Deserialize, Debug, Copy, Clone)]
#[serde(rename_all = "camelCase")]
#[repr(u8)]
pub enum MQRequestMode {
    SimpleMessage = 0,
    CallAndResponse = 1,
    MessageReply = 2,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ZMessagePayload {
    pub message: CompactString,
}

pub struct ZMessageBuilder {
    mode: Option<MQRequestMode>,
    sequence_id: Option<u32>,
    message_type: Option<ZMessageType>,
    payload: Option<ZMessagePayload>,
}

impl ZMessageBuilder {
    // Create a new ZMessageBuilder
    pub fn new() -> ZMessageBuilder {
        ZMessageBuilder {
            mode: None,
            sequence_id: None,
            message_type: None,
            payload: None,
        }
    }
    
    pub fn new_heartbeat() -> ZMessageBuilder {
        ZMessageBuilder {
            mode: Some(MQRequestMode::SimpleMessage),
            sequence_id: Some(0),
            message_type: Some(ZMessageType::MsgKeepAlive),
            payload: None,
        }
    }
    
    
    
    pub fn new_mq_command_string(command: CompactString) -> ZMessageBuilder
    {
        ZMessageBuilder {
            mode: Some(MQRequestMode::SimpleMessage),
            sequence_id: Some(0),
            message_type: Some(ZMessageType::MsgMQCommandString),
            payload: Some(ZMessagePayload {
                message: command,
            }),
        }
    }
    
    // Set the mode
    pub fn mode(mut self, mode: MQRequestMode) -> ZMessageBuilder {
        self.mode = Some(mode);
        self
    }

    // Set the sequence_id
    pub fn sequence_id(mut self, sequence_id: u32) -> ZMessageBuilder {
        self.sequence_id = Some(sequence_id);
        self
    }

    // Set the message_type
    pub fn message_type(mut self, message_type: ZMessageType) -> ZMessageBuilder {
        self.message_type = Some(message_type);
        self
    }

    // Set the payload
    pub fn payload(mut self, payload: ZMessagePayload) -> ZMessageBuilder {
        self.payload = Some(payload);
        self
    }

    // Build the ZMessage, consuming the builder
    pub fn build(self) -> Result<ZMessage> {
        if self.mode.is_none() {
            return Err(anyhow!("Mode is missing"));
        }
        if self.sequence_id.is_none() {
            return Err(anyhow!("Sequence ID is missing"));
        }
        if self.message_type.is_none() {
            return Err(anyhow!("Message type is missing"));
        }
        Ok(ZMessage {
            mode: self.mode.unwrap(),
            sequence_id: self.sequence_id.unwrap(),
            message_type: self.message_type.unwrap(),
            payload: self.payload,
        })
    }
}

#[derive(Serialize, Deserialize, Debug, Clone)]
//#[repr(C, packed)]
pub struct ZMessage {
    pub mode: MQRequestMode,
    pub sequence_id: u32,
    pub message_type: ZMessageType,
    pub payload: Option<ZMessagePayload>,
}


#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Channel(pub CompactString);

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Room(pub CompactString);

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Character(pub CompactString);

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
