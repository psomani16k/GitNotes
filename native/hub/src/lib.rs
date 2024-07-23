//! This `hub` crate is the
//! entry point of the Rust logic.

mod common;
mod messages;
use gix::{clone::PrepareFetch, filter::plumbing::worktree};
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

            let url = "https://github.com/psomani16k/Diraudio.git";

            unsafe {
                gix::interrupt::init_handler(1, || {});
            }

            let mut url = gix::url::parse(url.into()).unwrap();

            url.set_user(Some(String::from("psomani16k")));
            url.set_password(Some(String::from("Astrophotography101")));

            let url_scheme = url.clone().scheme;
            debug_print!("Scheme: {}", url_scheme.as_str());

            let mut prepare_clone = gix::prepare_clone(url, dir_path).unwrap();

            let (mut prepare_checkout, _) = prepare_clone
                .fetch_then_checkout(gix::progress::Discard, &gix::interrupt::IS_INTERRUPTED)
                .unwrap();

            debug_print!(
                "Checking out into {:?} ...",
                prepare_checkout.repo().work_dir().expect("should be there")
            );

            let (repo, _) = prepare_checkout
                .main_worktree(gix::progress::Discard, &gix::interrupt::IS_INTERRUPTED)
                .unwrap();
            debug_print!(
                "Repo cloned into {:?}",
                repo.work_dir().expect("directory pre-created")
            );

            let remote = repo
                .find_default_remote(gix::remote::Direction::Fetch)
                .expect("always present after clone")
                .unwrap();

            debug_print!(
                "Default remote: {} -> {}",
                remote
                    .name()
                    .expect("default remote is always named")
                    .as_bstr(),
                remote
                    .url(gix::remote::Direction::Fetch)
                    .expect("should be the remote URL")
                    .to_bstring(),
            );
        }
    }
}
