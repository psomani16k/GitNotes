pub mod clone_repo {

    use std::{fs::create_dir_all, path::Path};

    use git2::{build::RepoBuilder, CertificateCheckStatus, Cred, FetchOptions, RemoteCallbacks};

    use crate::git_functions::{
        errors::git_errors::GitError, git_checkout::branch_repo::current_branch,
    };

    /// Attempts to clone the repo form the url provided with the credentials provided.
    /// Creates a new directory in the path provided named UserName_RepoName where the clone takes place.
    /// Returns the directory name if clone succeeds or a [GitError] if fails.
    pub fn git_clone_https(
        url: String,
        dir_path: String,
        password: Option<String>,
        user: String,
    ) -> Result<(String, String), GitError> {
        match unsafe { git2::opts::set_verify_owner_validation(false) } {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "git_clone - 1".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        // creating a callback object
        let mut callbacks = RemoteCallbacks::new();
        callbacks.certificate_check(|_, _| Ok(CertificateCheckStatus::CertificateOk));

        // adding the credentials to the callback
        callbacks.credentials(move |_a: &str, _b, _c| match &password {
            Some(pass) => Cred::userpass_plaintext(&user, &pass),
            None => Cred::username(&user),
        });

        // creating fetch options
        let mut fetch_options = FetchOptions::new();
        fetch_options.remote_callbacks(callbacks);

        // creating a new directory in the provided directory with name as {user_name}_{repo_name}
        let new_dir = match get_directory_name_from_url(&url) {
            Ok(dir) => dir,
            Err(err) => {
                return Err(GitError::new("git_clone - 2".to_string(), err));
            }
        };

        let dir_path = format!("{}/{}", dir_path, new_dir);
        let dir_path_string = dir_path.to_string();
        let dir_path = Path::new(&dir_path);
        match create_dir_all(dir_path) {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new("git_clone - 3".to_string(), err.to_string()));
            }
        };

        // attempting to clone the repository
        let mut repo_builder = RepoBuilder::new();
        repo_builder.fetch_options(fetch_options);
        match repo_builder.clone(&url, Path::new(&dir_path)) {
            Ok(repo) => repo,
            Err(err) => {
                let path = Path::new(&dir_path);
                let _ = std::fs::remove_dir_all(path);
                return Err(GitError::new(
                    "git_clone - 4".to_string(),
                    err.message().to_string(),
                ));
            }
        };

        let branch = current_branch(&dir_path_string);
        return Ok((new_dir, branch));
    }

    fn get_directory_name_from_url(url: &str) -> Result<String, String> {
        let stripped_url = match url.strip_suffix(".git") {
            Some(stripped) => stripped,
            None => url,
        };
        let mut split_url = stripped_url.split("/").collect::<Vec<&str>>();
        split_url.reverse();
        let repo_name = match split_url.get(0) {
            Some(name) => *name,
            None => {
                return Err(
                    "Could not parse the url for repository name to create a directory name"
                        .to_string(),
                )
            }
        };
        let user_name = match split_url.get(1) {
            Some(name) => *name,
            None => {
                return Err(
                    "Could not parse the url for user name to create a directory name".to_string(),
                )
            }
        };
        return Ok(format!("{}/{}", user_name, repo_name));
    }
}
