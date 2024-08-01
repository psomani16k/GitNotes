pub mod clone_public_repo {
    use gix::Url;

    use crate::git_functions::errors::git_errors::CloneError;

    use std::{fs, path::Path};

    pub fn clone_repo(url: &str, dir_path: String) -> Result<String, CloneError> {
        unsafe {
            let _ = gix::interrupt::init_handler(1, || {});
        }

        let url = match gix::url::parse(url.into()) {
            Ok(url) => url,
            Err(err) => return Err(CloneError::new(err.to_string())),
        };

        let repo_folder = repo_name(&url);

        let dir_path = dir_path + "/" + &repo_folder;

        match fs::create_dir_all(&dir_path) {
            Ok(_) => {}
            Err(err) => {
                return Err(CloneError::new(format!(
                    "Failed to create repo directory, reason: {}",
                    err.to_string()
                )))
            }
        };

        let target_dir_path = Path::new(&dir_path);

        let mut prepare_clone = match gix::prepare_clone(url, target_dir_path) {
            Ok(prepare_clone) => prepare_clone,
            Err(err) => return Err(CloneError::new(err.to_string())),
        };

        let mut prepare_checkout = match prepare_clone
            .fetch_then_checkout(gix::progress::Discard, &gix::interrupt::IS_INTERRUPTED)
        {
            Ok((prep_checkout, _)) => prep_checkout,
            Err(err) => return Err(CloneError::new(err.to_string())),
        };

        let repo = match prepare_checkout
            .main_worktree(gix::progress::Discard, &gix::interrupt::IS_INTERRUPTED)
        {
            Ok((repo, _)) => repo,
            Err(err) => return Err(CloneError::new(err.to_string())),
        };

        let _ = match repo
            .find_default_remote(gix::remote::Direction::Fetch)
            .expect("always present after clone")
        {
            Ok(remote) => remote,
            Err(err) => return Err(CloneError::new(err.to_string())),
        };

        return Ok(dir_path);
    }

    fn repo_name(url: &Url) -> String {
        let url_path = url.path_argument_safe().unwrap();
        let url_path = url_path.to_string();
        let url_path: Vec<&str> = url_path.split("/").collect();
        let url_path = *url_path.last().unwrap();
        let repo_name = url_path
            .strip_suffix(".git")
            .unwrap_or(url_path)
            .to_string();
        println!("{}", repo_name);
        return repo_name;
    }
}
