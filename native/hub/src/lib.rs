mod common;
mod git_functions;
mod messages;

use git_functions::clone_repo::clone_repo::clone_repo_with_password;
use messages::clone::{CloneCallback, CloneRepo, CloneResult};
use tokio;
rinf::write_interface!();

async fn main() {
    tokio::spawn(clone_handler());
}

async fn clone_handler() {
    let mut reciever = CloneRepo::get_dart_signal_receiver().unwrap();
    while let Some(dart_signal) = reciever.recv().await {
        let message = dart_signal.message;
        let url = message.repo_url;
        let dir_path = message.directory_path;
        let user = message.user;
        let password = match message.password.as_str() {
            "" => None,
            pass => Some(pass.to_string()),
        };
        let clone_result = match clone_repo_with_password(url, dir_path, password, user) {
            Ok(dir_path) => CloneCallback {
                status: CloneResult::Success.into(),
                data: dir_path,
            },
            Err(err) => CloneCallback {
                status: CloneResult::Fail.into(),
                data: err.to_string(),
            },
        };
        clone_result.send_signal_to_dart();
    }
}
