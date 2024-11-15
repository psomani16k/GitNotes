pub mod restore_file {
    use std::path::Path;

    use git2::Repository;

    use crate::git_functions::errors::git_errors::GitError;

    pub fn restore_file(repo_dir: String, file_absolute_path: String) -> Result<(), GitError> {
        let file_path = file_absolute_path[repo_dir.len() + 1..].to_string();
        let repo = match Repository::open(Path::new(&repo_dir)) {
            Ok(repo) => repo,
            Err(err) => {
                return Err(GitError::new(
                    "SF_E0".to_string(),
                    err.message().to_string(),
                ))
            }
        };

        let last_commit_tree = repo
            .head()
            .unwrap()
            .peel_to_commit()
            .unwrap()
            .tree()
            .unwrap();

        if let Ok(entry) = last_commit_tree.get_path(Path::new(&file_path)) {
            let id = entry.id();
            let blob = repo.find_blob(id).unwrap();
            let file_content = blob.content();
            match std::fs::write(file_absolute_path, file_content) {
                Ok(_) => {}
                Err(err) => return Err(GitError::new("RF_E2".to_string(), err.to_string())),
            }
        }

        Ok(())
    }
}
