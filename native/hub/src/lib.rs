mod git_functions;
mod handlers;
mod messages;

use handlers::{
    commit_push_check_handler, git_add_handler, git_clone_handler, git_commit_handler,
    git_pull_single_handler, git_push_handler, git_remove_handler, git_restore_handler,
    git_status_handler,
};
use rinf::debug_print;
use tokio::{self, time}; // Comment this line to target the web.

rinf::write_interface!();

#[macro_use]
extern crate log;
extern crate android_log;

async fn main() {
    match android_log::init("GitNotes") {
        Ok(_) => {}
        Err(err) => {
            debug_print!("Error starting logger: {}", err.to_string());
        }
    };
    tokio::spawn(git_clone_handler());
    tokio::spawn(git_pull_single_handler());
    tokio::spawn(git_status_handler());
    tokio::spawn(git_add_handler());
    tokio::spawn(git_remove_handler());
    tokio::spawn(git_restore_handler());
    tokio::spawn(git_commit_handler());
    tokio::spawn(git_push_handler());
    tokio::spawn(commit_push_check_handler());
}
