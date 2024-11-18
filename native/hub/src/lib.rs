mod git_functions;
mod handlers;
mod messages;

use handlers::{
    commit_push_check_handler, git_add_handler, git_clone_handler, git_commit_handler,
    git_pull_single_handler, git_push_handler, git_remove_handler, git_restore_handler,
    git_status_handler,
};
use tokio; // Comment this line to target the web.

rinf::write_interface!();
async fn main() {
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
