pub mod branch_repo {
    use git2::Branches;

    use crate::git_functions::errors::git_errors::GitError;

    pub fn list_branches(repo: &git2::Repository) -> Result<Branches, GitError> {
        match repo.branches(Some(git2::BranchType::Local)) {
            Ok(branches) => Ok(branches),
            Err(err) => Err(GitError::new(
                "BR_E1".to_string(),
                err.message().to_string(),
            )),
        }
    }

    pub fn checkout_branch(repo: &git2::Repository, branch_name: String) -> Result<(), GitError> {
        let (object, reference) = match repo.revparse_ext(branch_name.as_str()) {
            Ok(data) => data,

            Err(err) => {
                return Err(GitError::new(
                    "BR_E2".to_string(),
                    err.message().to_string(),
                ))
            }
        };

        match repo.checkout_tree(&object, None) {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "BR_E3".to_string(),
                    err.message().to_string(),
                ))
            }
        };

        let temp = match reference {
            Some(r) => repo.set_head(r.name().unwrap()),
            None => repo.set_head_detached(object.id()),
        };

        match temp {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "BR_E4".to_string(),
                    err.message().to_string(),
                ))
            }
        }
        Ok(())
    }
}
