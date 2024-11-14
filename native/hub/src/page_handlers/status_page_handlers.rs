pub mod status_page_handlers {
    use crate::{
        git_functions::{
            commit_stage::commit_stage::commit_staged_files,
            push_commit::push_commits::push,
            restore_file::restore_file::restore_file,
            stage_file::stage_file::{add_all_to_stage, add_to_stage, remove_from_stage},
            status::status::get_status,
        },
        messages::{
            git_page_interactions::{
                CommitFiles, PushCommits, RevertFile, StageAllFiles, StageFile, UnStageFile,
                UnsyncedCommits, UpdatePage,
            },
            snack_error::SnackError,
        },
    };

    // Staging and un-staging files
    pub async fn handle_add_to_stage() {
        let mut recv = StageFile::get_dart_signal_receiver().unwrap();
        while let Some(message) = recv.recv().await {
            let file_path = message.message.file_absolute_path;
            let repo_path = message.message.repo_dir;
            match add_to_stage(repo_path.clone(), file_path) {
                Ok(_) => {
                    let status = get_status(repo_path).unwrap();
                    UpdatePage {
                        status,
                        unsynced_commits: UnsyncedCommits::Unchanged.into(),
                    }
                    .send_signal_to_dart();
                }
                Err(err) => {
                    SnackError {
                        error_message: format!("Couldn't stage file: {}", err),
                    }
                    .send_signal_to_dart();
                }
            };
        }
    }

    pub async fn handle_remove_from_stage() {
        let mut recv = UnStageFile::get_dart_signal_receiver().unwrap();
        while let Some(message) = recv.recv().await {
            let file_path = message.message.file_absolute_path;
            let repo_path = message.message.repo_dir;
            match remove_from_stage(repo_path.clone(), file_path) {
                Ok(_) => {
                    let status = get_status(repo_path).unwrap();
                    UpdatePage {
                        status,
                        unsynced_commits: UnsyncedCommits::Unchanged.into(),
                    }
                    .send_signal_to_dart();
                }
                Err(err) => {
                    SnackError {
                        error_message: format!("Couldn't un-stage file: {}", err),
                    }
                    .send_signal_to_dart();
                }
            };
        }
    }

    pub async fn handle_stage_all_files() {
        let mut recv = StageAllFiles::get_dart_signal_receiver().unwrap();
        while let Some(message) = recv.recv().await {
            let repo_path = message.message.repo_dir;
            match add_all_to_stage(repo_path.clone()) {
                Ok(_) => {
                    let status = get_status(repo_path).unwrap();
                    UpdatePage {
                        status,
                        unsynced_commits: UnsyncedCommits::Unchanged.into(),
                    }
                    .send_signal_to_dart();
                }
                Err(err) => {
                    SnackError {
                        error_message: format!("Couldn't stage file: {}", err),
                    }
                    .send_signal_to_dart();
                }
            };
        }
    }

    pub async fn handle_revert_file() {
        let mut recv = RevertFile::get_dart_signal_receiver().unwrap();
        while let Some(message) = recv.recv().await {
            let file_path = message.message.file_absolute_path;
            let repo_path = message.message.repo_dir;
            match restore_file(repo_path.clone(), file_path) {
                Ok(_) => {
                    let status = get_status(repo_path).unwrap();
                    UpdatePage {
                        status,
                        unsynced_commits: UnsyncedCommits::Unchanged.into(),
                    }
                    .send_signal_to_dart();
                }
                Err(err) => {
                    SnackError {
                        error_message: format!("Couldn't restore file: {}", err),
                    }
                    .send_signal_to_dart();
                }
            };
        }
    }

    pub async fn handle_commit() {
        let mut recv = CommitFiles::get_dart_signal_receiver().unwrap();
        while let Some(message) = recv.recv().await {
            let repo_path = message.message.repo_dir;
            let user_name = message.message.user_name;
            let user_email = message.message.user_email;
            let message = message.message.message;

            match commit_staged_files(repo_path.clone(), user_name, user_email, message) {
                Ok(_) => {
                    let status = get_status(repo_path).unwrap();
                    UpdatePage {
                        status,
                        unsynced_commits: UnsyncedCommits::Unchanged.into(),
                    }
                    .send_signal_to_dart();
                }
                Err(err) => {
                    SnackError {
                        error_message: format!("Couldn't commit files: {}", err),
                    }
                    .send_signal_to_dart();
                }
            };
        }
    }

    pub async fn handle_push() {
        let mut recv = PushCommits::get_dart_signal_receiver().unwrap();
        while let Some(message) = recv.recv().await {
            let repo_path = message.message.repo_dir;
            let user = message.message.user;
            let password = match message.message.password.as_str() {
                "" => None,
                pass => Some(pass.to_string()),
            };

            match push(repo_path.clone(), user, password) {
                Ok(_) => {
                    let status = get_status(repo_path).unwrap();
                    UpdatePage {
                        status,
                        unsynced_commits: UnsyncedCommits::NoExist.into(),
                    }
                    .send_signal_to_dart();
                }
                Err(err) => {
                    SnackError {
                        error_message: format!("Couldn't commit files: {}", err),
                    }
                    .send_signal_to_dart();
                }
            };
        }
    }
}
