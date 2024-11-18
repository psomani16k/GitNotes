use crate::{
    git_functions::{
        git_clone::clone_repo::git_clone_https, git_pull::pull_repo::git_pull,
        git_status::status::git_status,
    },
    messages::{
        git_clone::{GitCloneCallback, GitCloneRequest, GitCloneResult},
        git_pull::{GitPullResult, GitPullSingle, GitPullSingleCallback},
        git_status::{GitStatus, GitStatusCallback},
    },
};

pub async fn git_clone_handler() {
    let mut reciever = GitCloneRequest::get_dart_signal_receiver().unwrap();
    while let Some(dart_signal) = reciever.recv().await {
        let message = dart_signal.message;
        let url = message.repo_url;
        let dir_path = message.directory_path;
        let user = message.user;
        let password = match message.password.as_str() {
            "" => None,
            pass => Some(pass.to_string()),
        };

        let clone_result = git_clone_https(url, dir_path, password, user);

        let callback = match clone_result {
            Ok((dir_path, branch)) => GitCloneCallback {
                status: GitCloneResult::Success.into(),
                branch: branch,
                data: dir_path,
            },
            Err(err) => GitCloneCallback {
                status: GitCloneResult::Fail.into(),
                branch: "".to_string(),
                data: err.to_string(),
            },
        };
        callback.send_signal_to_dart();
    }
}

pub async fn git_pull_single_handler() {
    let mut recv = GitPullSingle::get_dart_signal_receiver().unwrap();
    while let Some(dart_signal) = recv.recv().await {
        let message = dart_signal.message;
        let dir_path = message.directory_path;
        let user = message.user;
        let password = match message.password.as_str() {
            "" => None,
            pass => Some(pass.to_string()),
        };

        let pull_result = git_pull(dir_path, password, user);

        let callback = match pull_result {
            Ok(result) => GitPullSingleCallback {
                status: GitPullResult::Success.into(),
                data: result,
            },
            Err(err) => GitPullSingleCallback {
                status: GitPullResult::Fail.into(),
                data: err.to_string(),
            },
        };
        callback.send_signal_to_dart();
    }
}

pub async fn git_status_handler() {
    let mut recv = GitStatus::get_dart_signal_receiver().unwrap();
    while let Some(dart_signal) = recv.recv().await {
        let message = dart_signal.message;
        let dir_path = message.repo_directory;

        let status_result = git_status(dir_path);

        let callback = match status_result {
            Ok(result) => GitStatusCallback { status: result },
            Err(err) => GitStatusCallback {
                status: vec![format!("ERROR: {}", err.to_string())],
            },
        };
        callback.send_signal_to_dart();
    }
}
