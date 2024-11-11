pub mod clone_repo {

    use std::{fs::create_dir_all, path::Path, str::FromStr};

    use git2::{build::RepoBuilder, CertificateCheckStatus, Cred, FetchOptions, RemoteCallbacks};

    use crate::git_functions::{
        branch_repo::branch_repo::{checkout_branch, list_branches},
        errors::git_errors::GitError,
    };

    /// Attempts to clone the repo form the url provided with the credentials provided.
    /// Creates a new directory in the path provided named UserName_RepoName where the clone takes place.
    /// Returns the directory name if clone succeeds or a [GitError] if fails.
    pub fn clone_repo_git2(
        url: String,
        dir_path: String,
        password: Option<String>,
        user: String,
    ) -> Result<(String, String), GitError> {
        // creating a callback object
        let mut callbacks = RemoteCallbacks::new();
        callbacks.certificate_check(|_, _| Ok(CertificateCheckStatus::CertificateOk));

        let user_copy = user.clone();
        let password_copy = password.clone();

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
                return Err(GitError::new("CR_E1".to_string(), err));
            }
        };
        let dir_path = format!("{}/{}", dir_path, new_dir);
        let dir_path = Path::new(&dir_path);
        match create_dir_all(dir_path) {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new("CR_E2".to_string(), err.to_string()));
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
                    "CR_E3".to_string(),
                    err.message().to_string(),
                ));
            }
        };

        // finding the branch and checking out to main if available.
        let repo = git2::Repository::open(dir_path).expect("Should be available here...");

        let branches =
            list_branches(&repo, user_copy, password_copy).expect("needs error handling here");
        let branch = match checkout_branch(&repo, "main".to_string(), false) {
            Ok(_) => String::from_str("main").unwrap(),
            Err(_) => {
                checkout_branch(
                    &repo,
                    branches
                        .first()
                        .expect("there should be atleast one branch!")
                        .to_string(),
                    false,
                )
                .unwrap();
                branches.first().unwrap().to_string()
            }
        };
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
        return Ok(format!("{}_{}", user_name, repo_name));
    }
}
