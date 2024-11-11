mod common;
mod git_functions;
mod messages;

use git_functions::git_handlers::git_handlers::{
    checkout_handler, clone_handler, list_branches_handler, pull_single_handler, status_handler
};
use tokio;
rinf::write_interface!();

async fn main() {
    tokio::spawn(clone_handler());
    tokio::spawn(pull_single_handler());
    tokio::spawn(checkout_handler());
    tokio::spawn(list_branches_handler());
    tokio::spawn(status_handler());
}
