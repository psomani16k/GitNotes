pub mod branch_repo {
    use git2::{build::CheckoutBuilder, CertificateCheckStatus, Cred, Repository};

    use crate::git_functions::errors::git_errors::GitError;

    // pub fn list_branches(
    //     repo: &git2::Repository,
    //     user: String,
    //     password: Option<String>,
    // ) -> Result<Vec<String>, GitError> {
    //     match unsafe { git2::opts::set_verify_owner_validation(false) } {
    //         Ok(_) => {}
    //         Err(err) => {
    //             return Err(GitError::new(
    //                 "BR_E0".to_string(),
    //                 err.message().to_string(),
    //             ))
    //         }
    //     };
    //     let mut remote = match repo.find_remote("origin") {
    //         Ok(remote) => remote,
    //         Err(err) => {
    //             return Err(GitError::new(
    //                 "BR_E1".to_string(),
    //                 err.message().to_string(),
    //             ))
    //         }
    //     };

    //     let mut callback = git2::RemoteCallbacks::new();
    //     callback.certificate_check(|_, _| Ok(CertificateCheckStatus::CertificateOk));

    //     callback.credentials(|_a, _b, _c| match &password {
    //         Some(pass) => Cred::userpass_plaintext(user.as_str(), pass.as_str()),
    //         None => Cred::username(user.as_str()),
    //     });

    //     match remote.connect_auth(git2::Direction::Fetch, Some(callback), None) {
    //         Ok(_) => {}
    //         Err(err) => {
    //             return Err(GitError::new(
    //                 "BR_E3".to_string(),
    //                 err.message().to_string(),
    //             ))
    //         }
    //     };

    //     let branches = match remote.list() {
    //         Ok(branches) => branches,
    //         Err(err) => {
    //             return Err(GitError::new(
    //                 "BR_E2".to_string(),
    //                 err.message().to_string(),
    //             ))
    //         }
    //     };
    //     let mut names: Vec<String> = Vec::new();
    //     for branch in branches {
    //         let name = branch.name().to_string();
    //         names.push(name);
    //     }
    //     return Ok(names);
    // }

    pub fn current_branch(repo_dir: &str) -> String {
        unsafe {
            let _ = git2::opts::set_verify_owner_validation(false);
        }
        let repo = Repository::open(repo_dir).unwrap();
        let head = repo.head().unwrap();
        return head.shorthand().unwrap().to_string();
    }

    // pub fn git_checkout(
    //     repo: &git2::Repository,
    //     branch_name: String,
    //     force: bool,
    // ) -> Result<(), GitError> {
    //     match unsafe { git2::opts::set_verify_owner_validation(false) } {
    //         Ok(_) => {}
    //         Err(err) => {
    //             return Err(GitError::new(
    //                 "BR_E7".to_string(),
    //                 err.message().to_string(),
    //             ))
    //         }
    //     };
    //     let branch = match repo.find_reference(&format!("refs/remotes/origin/{}", branch_name)) {
    //         Ok(branch) => branch,
    //         Err(err) => {
    //             return Err(GitError::new(
    //                 "BR_E4".to_string(),
    //                 err.message().to_string(),
    //             ))
    //         }
    //     };

    //     let target_commit = match branch.peel_to_commit() {
    //         Ok(target_commit) => target_commit,
    //         Err(err) => {
    //             return Err(GitError::new(
    //                 "BR_E5".to_string(),
    //                 err.message().to_string(),
    //             ))
    //         }
    //     };

    //     let mut checkout_builder = CheckoutBuilder::new();

    //     if force {
    //         checkout_builder.force();
    //     }

    //     match repo.checkout_tree(&target_commit.as_object(), Some(&mut checkout_builder)) {
    //         Ok(_) => {}
    //         Err(err) => {
    //             return Err(GitError::new(
    //                 "BR_E3".to_string(),
    //                 err.message().to_string(),
    //             ))
    //         }
    //     };

    //     match repo.set_head(&format!("refs/remotes/origin/{}", branch_name)) {
    //         Ok(_) => {}
    //         Err(err) => {
    //             return Err(GitError::new(
    //                 "BR_E6".to_string(),
    //                 err.message().to_string(),
    //             ))
    //         }
    //     };

    //     Ok(())
    // }
}
