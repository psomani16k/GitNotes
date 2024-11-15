pub mod push_commits {
    use std::path::Path;

    use git2::{CertificateCheckStatus, Cred, PushOptions, RemoteCallbacks, Repository};

    use crate::git_functions::errors::git_errors::GitError;

    pub fn git_push(repo_dir: String, user: String, password: Option<String>) -> Result<(), GitError> {
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
        let branch = repo.head().unwrap();
        let branch = branch.name().unwrap();

        let mut callbacks = RemoteCallbacks::new();
        callbacks.certificate_check(|_, _| Ok(CertificateCheckStatus::CertificateOk));

        // adding the credentials to the callback
        callbacks.credentials(move |_a: &str, _b, _c| match &password {
            Some(pass) => Cred::userpass_plaintext(&user, &pass),
            None => Cred::username(&user),
        });
        let mut options = PushOptions::new();
        options.remote_callbacks(callbacks);
        match remote.push::<&str>(&[branch], Some(&mut options)) {
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
}
