mod common;
mod git_functions;
mod messages;
mod page_handlers;

use git_functions::git_handlers::git_handlers::{
    checkout_handler, clone_handler, list_branches_handler, pull_single_handler, status_handler
};
use page_handlers::status_page_handlers::status_page_handlers::{handle_add_to_stage, handle_commit, handle_push, handle_remove_from_stage, handle_revert_file, handle_stage_all_files};
use tokio;
rinf::write_interface!();

async fn main() {
    // general git functions
    tokio::spawn(clone_handler());
    tokio::spawn(pull_single_handler());
    tokio::spawn(checkout_handler());
    tokio::spawn(list_branches_handler());
    tokio::spawn(status_handler());

    // status page handlers
    tokio::spawn(handle_add_to_stage());
    tokio::spawn(handle_remove_from_stage());
    tokio::spawn(handle_stage_all_files());
    tokio::spawn(handle_revert_file());
    tokio::spawn(handle_commit());
    tokio::spawn(handle_push());
}
