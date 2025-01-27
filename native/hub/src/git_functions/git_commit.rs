pub mod commit_stage {
    use std::path::Path;

    use git2::{Repository, Signature, StatusOptions};

    use crate::git_functions::errors::git_errors::GitError;

    pub fn git_commit(
        repo_dir: String,
        name: String,
        email: String,
        message: String,
    ) -> Result<(), GitError> {
        match unsafe { git2::opts::set_verify_owner_validation(false) } {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "git_commit - 1".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let repo = match Repository::open(Path::new(&repo_dir)) {
            Ok(repo) => repo,
            Err(err) => {
                return Err(GitError::new(
                    "git_commit - 2".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        if !has_indexed_files(&repo) {
            return Err(GitError::new(
                "git_commit - 3".to_string(),
                "No files staged for commit".to_string(),
            ));
        }
        let mut index = repo.index().unwrap();
        let tree = match index.write_tree() {
            Ok(tree) => tree,
            Err(err) => {
                return Err(GitError::new(
                    "git_commit - 4".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let tree = match repo.find_tree(tree) {
            Ok(tree) => tree,
            Err(err) => {
                return Err(GitError::new(
                    "git_commit - 5".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let signature = Signature::now(&name, &email).unwrap();
        if let Ok(parent_commit) = repo.head() {
            match repo.commit(
                Some("HEAD"),
                &signature,
                &signature,
                &message,
                &tree,
                &[&parent_commit.peel_to_commit().unwrap()],
            ) {
                Ok(_) => {}
                Err(err) => {
                    return Err(GitError::new(
                        "git_commit - 6".to_string(),
                        err.message().to_string(),
                    ))
                }
            }
        } else {
            match repo.commit(Some("HEAD"), &signature, &signature, &message, &tree, &[]) {
                Ok(_) => {}
                Err(err) => {
                    return Err(GitError::new(
                        "git_commit - 7".to_string(),
                        err.message().to_string(),
                    ))
                }
            }
        }
        Ok(())
    }

    fn has_indexed_files(repo: &Repository) -> bool {
        let mut opts = StatusOptions::new();
        opts.include_ignored(false);
        opts.include_untracked(true).recurse_untracked_dirs(true);
        opts.exclude_submodules(true);

        let statuses = repo.statuses(Some(&mut opts)).unwrap();
        let statuses = statuses.iter();
        for i in statuses {
            let file_status = i.status();
            if file_status.is_index_renamed()
                || file_status.is_index_modified()
                || file_status.is_index_new()
                || file_status.is_index_deleted()
                || file_status.is_index_typechange()
            {
                return true;
            }
        }
        return false;
    }

    pub fn can_commit(repo_dir: &str) -> bool {
        unsafe {
            let _ = git2::opts::set_verify_owner_validation(false);
        };
        let repo = Repository::open(Path::new(&repo_dir)).unwrap();
        let mut opts = StatusOptions::new();
        opts.include_ignored(false);
        opts.include_untracked(true).recurse_untracked_dirs(true);
        opts.exclude_submodules(true);

        let statuses = repo.statuses(Some(&mut opts)).unwrap();
        let statuses = statuses.iter();
        for i in statuses {
            let file_status = i.status();
            if file_status.is_index_renamed()
                || file_status.is_index_modified()
                || file_status.is_index_new()
                || file_status.is_index_deleted()
                || file_status.is_index_typechange()
            {
                return true;
            }
        }
        return false;
    }
}
