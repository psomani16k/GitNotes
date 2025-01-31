pub mod status {
    use git2::{Repository, StatusOptions};

    use crate::{
        git_functions::errors::git_errors::GitError,
        messages::git_status::{GitFileStatus, Status},
    };

    pub fn git_status(path: String) -> Result<Vec<GitFileStatus>, GitError> {
        match unsafe { git2::opts::set_verify_owner_validation(false) } {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "git_status - 1".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let repo = match Repository::open(&path) {
            Ok(repo) => repo,
            Err(err) => {
                return Err(GitError::new(
                    "git_status - 2".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        if repo.is_bare() {
            return Err(GitError::new(
                "git_status - 3".to_string(),
                "cannot report status on bare repository".to_string(),
            ));
        }

        let mut opts = StatusOptions::new();
        opts.include_ignored(false);
        opts.include_untracked(true).recurse_untracked_dirs(true);
        opts.exclude_submodules(false);

        let statuses = repo.statuses(Some(&mut opts)).unwrap();
        return Ok(show_status(&statuses));
    }

    fn show_status(statuses: &git2::Statuses) -> Vec<GitFileStatus> {
        let mut file_statuses: Vec<GitFileStatus> = Vec::new();
        for entry in statuses.iter() {
            let status = match entry.status() {
                s if s.contains(git2::Status::WT_NEW) => Status::WorkTreeNew,
                s if s.contains(git2::Status::WT_MODIFIED) => Status::WorkTreeModified,
                s if s.contains(git2::Status::WT_DELETED) => Status::WorkTreeDeleted,
                s if s.contains(git2::Status::WT_RENAMED) => Status::WorkTreeRenamed,
                s if s.contains(git2::Status::WT_TYPECHANGE) => Status::WorkTreeTypechange,
                s if s.contains(git2::Status::INDEX_NEW) => Status::IndexNew,
                s if s.contains(git2::Status::INDEX_MODIFIED) => Status::IndexModified,
                s if s.contains(git2::Status::INDEX_DELETED) => Status::IndexDeleted,
                s if s.contains(git2::Status::INDEX_RENAMED) => Status::IndexRenamed,
                s if s.contains(git2::Status::INDEX_TYPECHANGE) => Status::IndexTypechange,
                _ => {
                    continue;
                }
            };
            let file_status = GitFileStatus {
                status: status.into(),
                file: entry.path().unwrap().to_owned(),
            };
            file_statuses.push(file_status);
        }
        return file_statuses;
    }
}
