pub mod git_handlers {
    use gix::submodule::config::branch;

    use crate::{
        git_functions::{
            branch_repo::branch_repo::{checkout_branch, list_branches},
            clone_repo::clone_repo::clone_repo_git2,
            pull_repo::pull_repo::pull_repo_git2,
            status::status::get_status,
        },
        messages::{
            checkout::{
                CheckoutBranch, CheckoutCallback, CheckoutStatus, ListBranches,
                ListBranchesCallback,
            },
            clone::{CloneCallback, CloneRepo, CloneResult},
            pull::{PullResult, PullSingleCallback, PullSingleRepo},
            status::{GetStatus, StatusCallBack},
        },
    };

    pub async fn pull_single_handler() {
        let mut reciever = PullSingleRepo::get_dart_signal_receiver().unwrap();
        while let Some(dart_signal) = reciever.recv().await {
            let message = dart_signal.message;
            let dir_path = message.directory_path;
            let user = message.user;
            let password = match message.password.as_str() {
                "" => None,
                pass => Some(pass.to_string()),
            };

            let pull_result = pull_repo_git2(dir_path, password, user);

            let callback = match pull_result {
                Ok(result) => PullSingleCallback {
                    status: PullResult::Success.into(),
                    data: result,
                },
                Err(err) => PullSingleCallback {
                    status: PullResult::Fail.into(),
                    data: err.to_string(),
                },
            };
            callback.send_signal_to_dart();
        }
    }

    pub async fn clone_handler() {
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

            let clone_result = clone_repo_git2(url, dir_path, password, user);

            // let clone_result = match git_implementation {
            //     GitImplementation::Git2 => clone_repo_git2(url, dir_path, password, user),
            //     GitImplementation::Gix => clone_repo_gix(url, dir_path, password, user),
            // };

            let callback = match clone_result {
                Ok((dir_path, branch)) => CloneCallback {
                    status: CloneResult::Success.into(),
                    branch: branch,
                    data: dir_path,
                },
                Err(err) => CloneCallback {
                    status: CloneResult::Fail.into(),
                    branch: "".to_string(),
                    data: err.to_string(),
                },
            };
            callback.send_signal_to_dart();
        }
    }

    pub async fn status_handler() {
        let mut reciever = GetStatus::get_dart_signal_receiver().unwrap();
        while let Some(dart_signal) = reciever.recv().await {
            let message = dart_signal.message;
            let dir_path = message.repo_directory;

            let status_result = get_status(dir_path);

            let callback = match status_result {
                Ok(result) => StatusCallBack { status: result },

                Err(_) => {
                    // TODO: find a way to manage this case too
                    continue;
                }
            };
            callback.send_signal_to_dart();
        }
    }

    pub async fn checkout_handler() {
        let mut reciever = CheckoutBranch::get_dart_signal_receiver().unwrap();
        while let Some(dart_signal) = reciever.recv().await {
            let message = dart_signal.message;
            let dir_path = message.dir_path;
            let branch = message.branch;
            let force = message.force;
            let repo = git2::Repository::open(dir_path).expect("should exist");
            let checkout_result = checkout_branch(&repo, branch.clone(), force);

            let callback = match checkout_result {
                Ok(_) => CheckoutCallback {
                    data: branch,
                    status: CheckoutStatus::Success.into(),
                },

                Err(err) => CheckoutCallback {
                    data: err.to_string(),
                    status: CheckoutStatus::Fail.into(),
                },
            };
            callback.send_signal_to_dart();
        }
    }

    pub async fn list_branches_handler() {
        let mut reciever = ListBranches::get_dart_signal_receiver().unwrap();
        while let Some(dart_signal) = reciever.recv().await {
            let message = dart_signal.message;
            let dir_path = message.dir_path;
            let password = match message.password.as_str() {
                "" => None,
                pass => Some(pass.to_string()),
            };
            let user = message.user;
            let repo = git2::Repository::open(dir_path).expect("should exist");
            let list_branch_result = list_branches(&repo, user, password);

            let callback = match list_branch_result {
                Ok(branches) => ListBranchesCallback {
                    branches: branches,
                    status: CheckoutStatus::Success.into(),
                },

                Err(err) => ListBranchesCallback {
                    branches: vec![err.to_string()],
                    status: CheckoutStatus::Fail.into(),
                },
            };
            callback.send_signal_to_dart();
        }
    }
}
