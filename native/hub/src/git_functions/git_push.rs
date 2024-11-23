pub mod push_commits {
    use std::path::Path;

    use git2::{CertificateCheckStatus, Cred, PushOptions, RemoteCallbacks, Repository};
    use rinf::debug_print;

    use crate::git_functions::{
        errors::git_errors::GitError, git_checkout::branch_repo::current_branch,
    };

    pub fn git_push(
        repo_dir: String,
        user: String,
        password: Option<String>,
    ) -> Result<(), GitError> {
        debug_print!("push called");
        match unsafe { git2::opts::set_verify_owner_validation(false) } {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "PR_E0".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let repo = Repository::open(Path::new(&repo_dir)).unwrap();
        let mut remote = repo.find_remote("origin").unwrap();

        // adding the credentials to the callback
        let password2 = password.clone();
        let user2 = user.clone();
        let mut callbacks = RemoteCallbacks::new();
        callbacks.certificate_check(|_, _| Ok(CertificateCheckStatus::CertificateOk));
        callbacks.credentials(move |_a: &str, _b, _c| match &password {
            Some(pass) => Cred::userpass_plaintext(&user, &pass),
            None => Cred::username(&user),
        });
        let mut options = PushOptions::new();
        options.remote_callbacks(callbacks);

        let mut callbacks2 = RemoteCallbacks::new();
        callbacks2.certificate_check(|_, _| Ok(CertificateCheckStatus::CertificateOk));
        callbacks2.credentials(move |_a: &str, _b, _c| match &password2 {
            Some(pass) => Cred::userpass_plaintext(&user2, &pass),
            None => Cred::username(&user2),
        });
        remote.connect_auth(git2::Direction::Push, Some(callbacks2), None).unwrap();

        // getting refspecs
        // this seems to be only returning "HEAD" on android... for now forcefully using "main" as the branch... need to investigate
        let branch = current_branch(&repo_dir);
        let refspec = format!("refs/heads/{}:refs/heads/{}", branch, branch);
        debug_print!("Starting push now");
        match remote.push::<&str>(&[&refspec], Some(&mut options)) {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "PR_E1".to_string(),
                    err.message().to_string(),
                ))
            }
        };

        Ok(())
    }

    pub fn can_push(repo_dir: &str) -> bool {
        unsafe {
            let _ = git2::opts::set_verify_owner_validation(false);
        };
        let repo = Repository::open(Path::new(&repo_dir)).unwrap();
        let branch = repo.head().unwrap();
        debug_print!("{}", branch.is_branch());
        let local_commit = branch.peel_to_commit().unwrap();
        let remote_ref = repo.find_reference("refs/remotes/origin/HEAD").unwrap();
        let remote_commit = remote_ref.peel_to_commit().unwrap();
        return remote_commit.id() != local_commit.id();
    }
}
