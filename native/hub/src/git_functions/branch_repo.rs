pub mod branch_repo {
    use git2::build::CheckoutBuilder;

    use crate::git_functions::errors::git_errors::GitError;

    pub fn list_branches(repo: &git2::Repository) -> Result<Vec<String>, GitError> {
        let remote = match repo.find_remote("origin") {
            Ok(remote) => remote,
            Err(err) => {
                return Err(GitError::new(
                    "BR_E1".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let branches = match remote.list() {
            Ok(branches) => branches,
            Err(err) => {
                return Err(GitError::new(
                    "BR_E2".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let mut names: Vec<String> = Vec::new();
        for branch in branches {
            let name = branch.name().to_string();
            names.push(name);
        }
        return Ok(names);
    }

    pub fn checkout_branch(
        repo: &git2::Repository,
        branch_name: String,
        force: bool,
    ) -> Result<(), GitError> {
        let branch = match repo.find_reference(&format!("refs/remotes/origin/{}", branch_name)) {
            Ok(branch) => branch,
            Err(err) => {
                return Err(GitError::new(
                    "BR_E4".to_string(),
                    err.message().to_string(),
                ))
            }
        };

        let target_commit = match branch.peel_to_commit() {
            Ok(target_commit) => target_commit,
            Err(err) => {
                return Err(GitError::new(
                    "BR_E5".to_string(),
                    err.message().to_string(),
                ))
            }
        };

        let mut checkout_builder = CheckoutBuilder::new();

        if force {
            checkout_builder.force();
        }

        match repo.checkout_tree(&target_commit.as_object(), Some(&mut checkout_builder)) {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "BR_E3".to_string(),
                    err.message().to_string(),
                ))
            }
        };

        match repo.set_head(&format!("refs/remotes/origin/{}", branch_name)) {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "BR_E6".to_string(),
                    err.message().to_string(),
                ))
            }
        };

        Ok(())
    }
}
