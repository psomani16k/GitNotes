pub mod pull_repo {
    use crate::git_functions::errors::git_errors::GitError;
    use git2::{AnnotatedCommit, Cred, FetchOptions, Reference};

    pub fn pull_repo_git2<'a>(
        dir_path: String,
        password: Option<String>,
        user: String,
        remote_branch: Option<String>,
    ) -> Result<String, GitError> {
        let repo = git2::Repository::open(dir_path).unwrap();
        let mut remote = match repo.find_remote("origin") {
            Ok(remote) => remote,
            Err(err) => return Err(GitError::new("PR_E1".to_string(), err.to_string())),
        };
        let remote_branch = remote_branch.unwrap_or("main".to_string());
        let remote_branch = remote_branch.as_str();
        let remote_branch_list = &[remote_branch];
        let fetch_annotated_commit =
            match do_fetch(&repo, remote_branch_list, &mut remote, user, password) {
                Ok(data) => data.1,
                Err(err) => return Err(GitError::new("PR_E2".to_string(), err.to_string())),
            };
        let msg = match do_merge(&repo, remote_branch, fetch_annotated_commit) {
            Ok(msg) => msg,
            Err(err) => return Err(GitError::new("PR_E3".to_string(), err.to_string())),
        };
        Ok(msg)
    }

    fn fast_forward(
        repo: &git2::Repository,
        referance: &mut Reference,
        fetch_commit: &git2::AnnotatedCommit,
    ) -> Result<(), GitError> {
        let name = match referance.name() {
            Some(name) => name.to_string(),
            None => String::from_utf8_lossy(referance.name_bytes()).to_string(),
        };
        let msg = format!(
            "Fast-Forward: Setting {} to id: {}",
            name,
            fetch_commit.id()
        );
        match referance.set_target(fetch_commit.id(), &msg) {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "PR_E4".to_string(),
                    err.message().to_string(),
                ));
            }
        };
        match repo.set_head(&name) {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "PR_E5".to_string(),
                    err.message().to_string(),
                ));
            }
        };

        match repo.checkout_head(Some(git2::build::CheckoutBuilder::default().force())) {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "PR_E6".to_string(),
                    err.message().to_string(),
                ));
            }
        };
        return Ok(());
    }

    fn normal_merge(
        repo: &git2::Repository,
        local: &git2::AnnotatedCommit,
        remote: &git2::AnnotatedCommit,
    ) -> Result<String, GitError> {
        let remote_tree = match repo.find_commit(remote.id()) {
            Ok(remote_tree) => remote_tree,
            Err(err) => {
                return Err(GitError::new(
                    "PR_E7".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let remote_tree = match remote_tree.tree() {
            Ok(remote_tree) => remote_tree,
            Err(err) => {
                return Err(GitError::new(
                    "PR_E8".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let local_tree = match repo.find_commit(local.id()) {
            Ok(local_tree) => local_tree,
            Err(err) => {
                return Err(GitError::new(
                    "PR_E9".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let local_tree = match local_tree.tree() {
            Ok(local_tree) => local_tree,
            Err(err) => {
                return Err(GitError::new(
                    "PR_E10".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let ancestors = match repo.find_commit(repo.merge_base(local.id(), remote.id()).unwrap()) {
            Ok(ancestors) => ancestors,
            Err(err) => {
                return Err(GitError::new(
                    "PR_E11".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let ancestors = match ancestors.tree() {
            Ok(ancestor) => ancestor,
            Err(err) => {
                return Err(GitError::new(
                    "PR_E12".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let mut idx = match repo.merge_trees(&ancestors, &local_tree, &remote_tree, None) {
            Ok(idx) => idx,
            Err(err) => {
                return Err(GitError::new(
                    "PR_E13".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        if idx.has_conflicts() {
            repo.checkout_index(Some(&mut idx), None).unwrap();
        }

        let oid = match idx.write_tree_to(repo) {
            Ok(oid) => oid,
            Err(err) => {
                return Err(GitError::new(
                    "PR_E14".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let result_tree = match repo.find_tree(oid) {
            Ok(result_tree) => result_tree,
            Err(err) => {
                return Err(GitError::new(
                    "PR_E15".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let return_msg = format!("Merge: {} into {}", remote.id(), local.id());
        let sig = repo.signature().unwrap();
        let local_commit = repo.find_commit(local.id()).unwrap();
        let remote_commit = repo.find_commit(remote.id()).unwrap();
        match repo.commit(
            Some("HEAD"),
            &sig,
            &sig,
            &return_msg,
            &result_tree,
            &[&local_commit, &remote_commit],
        ) {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "PR_E16".to_string(),
                    err.message().to_string(),
                ))
            }
        }
        return Ok(return_msg);
    }

    fn do_fetch<'a>(
        repo: &'a git2::Repository,
        refs: &'a [&'a str],
        remote: &'a mut git2::Remote,
        user: String,
        pass: Option<String>,
    ) -> Result<(String, AnnotatedCommit<'a>), GitError> {
        let mut callback = git2::RemoteCallbacks::new();

        callback.credentials(|_a,_b, _c| match &pass {
            Some(pass) => Cred::userpass_plaintext(user.as_str(), pass.as_str()),
            None => Cred::username(user.as_str()),
        });
        let mut fetch_options = FetchOptions::new();
        fetch_options.remote_callbacks(callback);
        fetch_options.download_tags(git2::AutotagOption::All);
        match remote.fetch(refs, Some(&mut fetch_options), None) {
            Ok(_) => {}
            Err(err) => {
                return Err(GitError::new(
                    "PR_E17".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let stats = remote.stats();
        let return_string = format!(
            "Recieved {} objects in {} bytes",
            stats.total_objects() - stats.local_objects(),
            stats.received_bytes()
        );
        let fetch_head = match repo.find_reference("FETCH_HEAD") {
            Ok(fetch_head) => fetch_head,
            Err(err) => {
                return Err(GitError::new(
                    "PR_E18".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let annotated_commit = match repo.reference_to_annotated_commit(&fetch_head) {
            Ok(annotated_commit) => annotated_commit,
            Err(err) => {
                return Err(GitError::new(
                    "PR_E19".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        return Ok((return_string, annotated_commit));
    }

    fn do_merge<'a>(
        repo: &'a git2::Repository,
        remote_branch: &'a str,
        fetch_commit: git2::AnnotatedCommit<'a>,
    ) -> Result<String, GitError> {
        let analysis = match repo.merge_analysis(&[&fetch_commit]) {
            Ok(analysis) => analysis,
            Err(err) => {
                return Err(GitError::new(
                    "PR_E20".to_string(),
                    err.message().to_string(),
                ))
            }
        };
        let result_string = String::new();
        if analysis.0.is_fast_forward() {
            let refname = format!("refs/heads/{}", remote_branch);
            let mut referance = match repo.find_reference(&refname) {
                Ok(referance) => referance,
                Err(_) => {
                    // The branch doesn't exist so just set the reference to the
                    // commit directly. Usually this is because you are pulling
                    // into an empty repository.
                    repo.reference(
                        &refname,
                        fetch_commit.id(),
                        true,
                        &format!("Setting {} to {}", remote_branch, fetch_commit.id()),
                    )
                    .unwrap();
                    repo.set_head(&refname).unwrap();
                    repo.checkout_head(Some(
                        git2::build::CheckoutBuilder::default()
                            .allow_conflicts(true)
                            .conflict_style_merge(true)
                            .force(),
                    ))
                    .unwrap();
                    return Ok("".to_string());
                }
            };
            match fast_forward(repo, &mut referance, &fetch_commit) {
                Ok(_) => {}
                Err(err) => return Err(err),
            };
        }
        return Ok(result_string);
    }
}
