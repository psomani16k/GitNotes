mod common;
mod messages;
mod handlers;
mod git_functions;

use handlers::{git_clone_handler, git_pull_single_handler, git_status_handler};
use tokio; // Comment this line to target the web.

rinf::write_interface!();
async fn main() {
    tokio::spawn(git_clone_handler());
    tokio::spawn(git_pull_single_handler());
    tokio::spawn(git_status_handler());
}
