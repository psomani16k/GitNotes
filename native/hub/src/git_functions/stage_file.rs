pub mod stage_file {
    use std::path::Path;

    use git2::{IndexAddOption, IndexEntry, IndexTime, Repository, StatusOptions};

    use crate::git_functions::errors::git_errors::GitError;

    pub fn add_to_stage(repo_dir: String, file_absolute_path: String) -> Result<(), GitError> {
        let file_path = file_absolute_path[repo_dir.len() + 1..].to_string();
        match unsafe { git2::opts::set_verify_owner_validation(false) } {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "CS_E1".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let repo = match Repository::open(Path::new(&repo_dir)) {
            Ok(repo) => repo,
            Err(err) => {
                return Err(GitError::new(
                    "SF_E0".to_string(),
                    err.message().to_string(),
                ))
            }
        };

        let mut index = repo.index().unwrap();

        let file_status = repo.status_file(Path::new(&file_path)).unwrap();

        if file_status.is_wt_renamed()
            || file_status.is_wt_modified()
            || file_status.is_wt_new()
            || file_status.is_wt_deleted()
            || file_status.is_wt_typechange()
        {
            match index.add_path(&Path::new(&file_path)) {
                Ok(_) => {}
                Err(err) => {
                    return Err(GitError::new(
                        "SF_E3".to_string(),
                        err.message().to_string(),
                    ))
                }
            };
        }

        match index.write() {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "SF_E4".to_string(),
                    err.message().to_string(),
                ))
            }
        };

        Ok(())
    }

    pub fn add_all_to_stage(repo_dir: String) -> Result<(), GitError> {
        match unsafe { git2::opts::set_verify_owner_validation(false) } {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "CS_E1".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let repo = match Repository::open(Path::new(&repo_dir)) {
            Ok(repo) => repo,
            Err(err) => {
                return Err(GitError::new(
                    "SF_E0".to_string(),
                    err.message().to_string(),
                ))
            }
        };

        let mut index = repo.index().unwrap();

        let mut opts = StatusOptions::new();
        opts.include_ignored(false);
        opts.include_untracked(true).recurse_untracked_dirs(true);
        opts.exclude_submodules(true);
        let statuses = repo.statuses(Some(&mut opts)).unwrap();
        let statuses = statuses.iter();
        let mut paths: Vec<String> = Vec::new();
        for i in statuses {
            let path = i.path().unwrap().to_string();
            paths.push(path);
        }
        match index.add_all(paths, IndexAddOption::DEFAULT, None) {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "SF_E3".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        match index.write() {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "SF_E4".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        Ok(())
    }

    pub fn remove_from_stage(repo_dir: String, file_absolute_path: String) -> Result<(), GitError> {
        let file_path = file_absolute_path[repo_dir.len() + 1..].to_string();
        let repo = match Repository::open(Path::new(&repo_dir)) {
            Ok(repo) => repo,
            Err(err) => {
                return Err(GitError::new(
                    "SF_E5".to_string(),
                    err.message().to_string(),
                ))
            }
        };

        let file_status = repo.status_file(Path::new(&file_path)).unwrap();
        let mut index = repo.index().unwrap();
        if file_status.is_index_new() {
            index.remove_path(Path::new(&file_path)).unwrap();
        }

        if file_status.is_index_renamed()
            || file_status.is_index_modified()
            || file_status.is_index_deleted()
            || file_status.is_index_typechange()
        {
            let last_commit = repo.head().unwrap().peel_to_commit().unwrap();
            let commit_tree = last_commit.tree().unwrap();
            let tree_entry = commit_tree.get_path(Path::new(&file_path)).unwrap();
            let current_index_entry = index.get_path(Path::new(&file_path), 0).unwrap();
            let mut new_index_entry = IndexEntry::from(current_index_entry);
            new_index_entry.ctime = IndexTime::new(0, 0);
            new_index_entry.mtime = IndexTime::new(0, 0);
            new_index_entry.dev = 0;
            new_index_entry.ino = 0;
            new_index_entry.uid = 0;
            new_index_entry.gid = 0;
            new_index_entry.file_size = 0;
            new_index_entry.id = tree_entry.id();
            new_index_entry.path = file_path.into();
            index.add(&new_index_entry).expect("should just work");
        }
        index.write().expect("should just work");

        Ok(())
    }
}
