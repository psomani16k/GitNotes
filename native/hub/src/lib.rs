//! This `hub` crate is the
//! entry point of the Rust logic.

mod common;
mod messages;
use gix::{
    clone::{self, fetch},
    refs::file::transaction::prepare,
};
// use gitoxide_core::repository;
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
            debug_print!("{dir_path}");

            let dir_path = Path::new(&dir_path);

            let url = "https://github.com/psomani16k/Diraudio";
            // let repo = match Repository::clone(url, dir_path) {
            //     Ok(repo) => {
            //         debug_print!("{:?}", repo.path().to_str());
            //     }
            //     Err(e) => {
            //         debug_print!("failed to clone: {}", e);
            //     }
            // };
            let url = "https://github.com/de-vri-es/auth-git2-rs";

            // Perform the clone operation
            let mut repo = gix::prepare_clone(url, dir_path).unwrap();

            // Optionally, perform additional operations with the cloned repository
            let mut prepare_checkout = repo
                .fetch_only(gix::progress::Discard, &gix::interrupt::IS_INTERRUPTED)
                .unwrap();
            let prepare_checkout = prepare_checkout.0;
            let mainRepo = prepare_checkout.main_repo().unwrap();
            let workTree = mainRepo.work_dir().unwrap();
            debug_print!("{:?}", workTree);
        }
    }
}
