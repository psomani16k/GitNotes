//! This `hub` crate is the
//! entry point of the Rust logic.

mod common;
mod messages;
mod git_functions;
use messages::basic::SmallText;
use rinf::debug_print;
use std::path::Path;

use tokio;
// Comment this line to target the web.
// use tokio_with_wasm::alias as tokio;
// Uncomment this line to target the web.

rinf::write_interface!();

// Use `tokio::spawn` to run concurrent tasks.
// Always use non-blocking async functions
// such as `tokio::fs::File::open`.
// If you really need to use blocking code,
// use `tokio::task::spawn_blocking`.
async fn main() {
    loop {
        let mut rec = SmallText::get_dart_signal_receiver().unwrap();
        let dir_path: String = "".to_string();
        while let Some(dir_path) = rec.recv().await {
            let dir_path = dir_path.message.text;
            
        }
    }
}
