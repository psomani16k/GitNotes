use tokio::sync::Mutex;

use crate::messages::git_push_pull_messages::GitPushPullMessage;

pub struct MessageBuffer {
    buffer: Vec<MessageType>,
}

pub static mut MESSAGE_BUFFER: Mutex<MessageBuffer> = Mutex::const_new(MessageBuffer::new());

impl MessageBuffer {
    const fn new() -> Self {
        return MessageBuffer { buffer: vec![] };
    }

    pub fn add(&mut self, message: MessageType) {
        self.buffer.push(message);
    }

    pub fn send_message(&mut self) {
        let msg = self.buffer.pop();
        if msg.is_some() {
            match msg.unwrap() {
                MessageType::GitPushPullMessageType(git_push_pull_message) => {
                    git_push_pull_message.send_signal_to_dart();
                }
            }
        }
    }
}

pub enum MessageType {
    GitPushPullMessageType(GitPushPullMessage),
}

pub trait PutToBuffer {
    async fn put_to_buffer(self);
}

impl PutToBuffer for GitPushPullMessage {
    async fn put_to_buffer(self) {
        let message = MessageType::GitPushPullMessageType(self);
        unsafe {
            let mut buf = MESSAGE_BUFFER.lock().await;
            buf.add(message);
        }
    }
}
