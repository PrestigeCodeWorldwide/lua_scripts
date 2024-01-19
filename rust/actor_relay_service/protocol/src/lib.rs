#![allow(non_snake_case, unused_variables, unused_mut, unused_imports)]

use derive_more::Display;
use serde::{Deserialize, Serialize};
use std::collections::{HashMap, HashSet};
use std::ops::Deref;
use tokio::net::TcpStream;
use tokio::{io::WriteHalf, sync::mpsc};
use uuid::Uuid;

#[derive(Debug, Display, Clone, Copy, Serialize, Deserialize, Eq, PartialEq, Hash)]
pub struct ClientId(pub Uuid);

impl ClientId {
    pub fn new() -> Self {
        Self(Uuid::new_v4())
    }

    pub fn get(&self) -> Uuid {
        self.0
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClientMessage {
    pub clientId: Option<ClientId>,
    pub clientOperation: ClientOperation,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ServerOperation {
    ClientConnectApproved(ClientId),
    RequestCurrentTaskStep,
}

/* intended as a grouping of clients, so things like
    "every one of your own characters" or "all the characters in the raid".
    String currently for flexibility until I figure out something better.
    Intended such that each client "connects" to one or more rooms at a time
    and each room has 1 or more channels.  A message is sent to a Room/Channel combination
*/
#[derive(Debug, Clone, Serialize, Deserialize, Display, PartialEq, Eq, Hash)]
pub struct Room(String);
#[derive(Debug, Clone, Serialize, Deserialize, Display, PartialEq, Eq, Hash)]
pub struct Channel(String);
#[derive(Debug, Clone, Serialize, Deserialize, Display, PartialEq, Eq, Hash)]
pub struct Message(String);

impl Deref for Room {
    type Target = String;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl Deref for Channel {
    type Target = String;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl Deref for Message {
    type Target = String;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ClientOperation {
    ConnectAttempt,  // connects to a socket
    RoomJoin(Room),  // joins a room
    RoomLeave(Room), // leaves a room
    Disconnect,
    Message {
        room: Room,
        channel: Channel,
        message: Message,
    },
}

pub struct Client {
    pub tx: mpsc::UnboundedSender<String>,
    pub clientId: ClientId,
}

impl Client {
    pub fn new(clientId: ClientId, tx: mpsc::UnboundedSender<String>) -> Self {
        Self { tx, clientId }
    }
}

pub struct Server {
    pub clients: HashMap<ClientId, Client>,
    pub writers: HashMap<ClientId, WriteHalf<TcpStream>>,
    pub rooms: HashMap<Room, HashSet<ClientId>>,
}
