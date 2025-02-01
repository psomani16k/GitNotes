use crate::{
    git_functions::{errors::git_errors::GitError, git_checkout::branch_repo::current_branch},
    messages::git_push_pull_messages::{GitPushPullMessage, PredefinedMsg},
};

use git2::{AnnotatedCommit, CertificateCheckStatus, Cred, FetchOptions, Signature};
use rinf::debug_print;

pub async fn git_pull(
    dir_path: String,
    password: Option<String>,
    email: String,
    name: String,
) -> Result<String, GitError> {
    // start git pull
    GitPushPullMessage {
        msg: "".to_string(),
        msg_index: 0,
        predefined_message: PredefinedMsg::Pull.into(),
    }
    .send_signal_to_dart();

    match unsafe { git2::opts::set_verify_owner_validation(false) } {
        Ok(_) => {}
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 0".to_string(),
                err.message().to_string(),
            ))
        }
    };

    let repo = git2::Repository::open(dir_path.clone()).unwrap();
    let mut remote = match repo.find_remote("origin") {
        Ok(remote) => remote,
        Err(err) => return Err(GitError::new("git_pull - 1".to_string(), err.to_string())),
    };

    let mut callback = git2::RemoteCallbacks::new();
    callback.certificate_check(|_, _| Ok(CertificateCheckStatus::CertificateOk));

    callback.credentials(|_a, _b, _c| match &password {
        Some(pass) => Cred::userpass_plaintext(email.as_str(), pass.as_str()),
        None => Cred::username(email.as_str()),
    });
    remote
        .connect_auth(git2::Direction::Fetch, Some(callback), None)
        .unwrap();

    let branch = current_branch(&dir_path);
    let b = vec![branch.clone()];
    let fetch_annotated_commit = match do_fetch(&repo, &b, &mut remote, email.clone(), password) {
        Ok(data) => data,
        Err(err) => return Err(err),
    };

    match do_merge(
        &repo,
        branch,
        &fetch_annotated_commit,
        name.clone(),
        email.clone(),
    ) {
        Ok(_) => {}
        Err(err) => return Err(err),
    };

    // end git pull
    GitPushPullMessage {
        msg_index: 10000,
        predefined_message: PredefinedMsg::End.into(),
        msg: "".to_string(),
    }
    .send_signal_to_dart();
    Ok("".to_string())
}

fn do_fetch<'a>(
    repo: &'a git2::Repository,
    refs: &'a Vec<String>,
    remote: &'a mut git2::Remote,
    user: String,
    pass: Option<String>,
) -> Result<AnnotatedCommit<'a>, GitError> {
    let mut callback = git2::RemoteCallbacks::new();
    callback.certificate_check(|_, _| Ok(CertificateCheckStatus::CertificateOk));

    callback.credentials(|_a, _b, _c| match &pass {
        Some(pass) => Cred::userpass_plaintext(user.as_str(), pass.as_str()),
        None => Cred::username(user.as_str()),
    });

    callback.sideband_progress(|stats| {
        let msg = format!("remote: {}", String::from_utf8_lossy(stats));
        debug_print!("{}", msg);
        GitPushPullMessage {
            predefined_message: PredefinedMsg::None.into(),
            msg_index: 1,
            msg,
        }
        .send_signal_to_dart();
        true
    });

    callback.transfer_progress(|stats| {
        if stats.received_objects() == stats.total_objects() {
            let msg = format!(
                "Resolving deltas {}/{}",
                stats.indexed_deltas(),
                stats.total_deltas()
            );
            debug_print!("{}", msg);
            GitPushPullMessage {
                predefined_message: PredefinedMsg::None.into(),
                msg_index: 2,
                msg,
            }
            .send_signal_to_dart();
        } else if stats.total_objects() > 0 {
            let msg = format!(
                "Received {}/{} objects ({}) in {} bytes",
                stats.received_objects(),
                stats.total_objects(),
                stats.indexed_objects(),
                stats.received_bytes()
            );
            debug_print!("{}", msg);
            GitPushPullMessage {
                predefined_message: PredefinedMsg::None.into(),
                msg_index: 3,
                msg,
            }
            .send_signal_to_dart();
        }
        true
    });
    let mut fetch_options = FetchOptions::new();
    fetch_options.remote_callbacks(callback);
    fetch_options.download_tags(git2::AutotagOption::All);
    match remote.fetch(refs, Some(&mut fetch_options), None) {
        Ok(_) => {}
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 16".to_string(),
                err.message().to_string(),
            ))
        }
    };
    let stats = remote.stats();
    if stats.total_objects() == 0 {
        debug_print!("Already up tp date.");
        GitPushPullMessage {
            predefined_message: PredefinedMsg::None.into(),
            msg_index: 30,
            msg: "Already up to date.".to_string(),
        }
        .send_signal_to_dart();
    } else if stats.local_objects() > 0 {
        let msg = format!(
            "Received {}/{} objects in {} bytes (used {} local objects)",
            stats.indexed_objects(),
            stats.total_objects(),
            stats.received_bytes(),
            stats.local_objects()
        );
        debug_print!("{}", msg);
        GitPushPullMessage {
            predefined_message: PredefinedMsg::None.into(),
            msg_index: 4,
            msg,
        }
        .send_signal_to_dart();
    } else {
        let msg = format!(
            "Received {}/{} objects in {} bytes",
            stats.indexed_objects(),
            stats.total_objects(),
            stats.received_bytes()
        );
        debug_print!("{}", msg);
        GitPushPullMessage {
            predefined_message: PredefinedMsg::None.into(),
            msg_index: 5,
            msg,
        }
        .send_signal_to_dart();
    }
    let fetch_head = match repo.find_reference("FETCH_HEAD") {
        Ok(fetch_head) => fetch_head,
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 17".to_string(),
                err.message().to_string(),
            ))
        }
    };
    let annotated_commit = match repo.reference_to_annotated_commit(&fetch_head) {
        Ok(annotated_commit) => annotated_commit,
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 18".to_string(),
                err.message().to_string(),
            ))
        }
    };
    return Ok(annotated_commit);
}

fn fast_forward(
    repo: &git2::Repository,
    referance: &mut git2::Reference,
    fetch_commit: &git2::AnnotatedCommit,
    // TODO: return the string here and add a merge message to be shown to user
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
    debug_print!("{}", msg);
    GitPushPullMessage {
        predefined_message: PredefinedMsg::None.into(),
        msg_index: 15,
        msg: msg.clone(),
    }
    .send_signal_to_dart();
    match referance.set_target(fetch_commit.id(), &msg) {
        Ok(_) => {}
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 3".to_string(),
                err.message().to_string(),
            ));
        }
    };
    match repo.set_head(&name) {
        Ok(_) => {}
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 4".to_string(),
                err.message().to_string(),
            ));
        }
    };

    match repo.checkout_head(Some(git2::build::CheckoutBuilder::default().force())) {
        Ok(_) => {}
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 5".to_string(),
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
    name: String,
    email: String,
) -> Result<(), GitError> {
    let remote_tree = match repo.find_commit(remote.id()) {
        Ok(remote_tree) => remote_tree,
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 6".to_string(),
                err.message().to_string(),
            ))
        }
    };
    let remote_tree = match remote_tree.tree() {
        Ok(remote_tree) => remote_tree,
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 7".to_string(),
                err.message().to_string(),
            ))
        }
    };
    let local_tree = match repo.find_commit(local.id()) {
        Ok(local_tree) => local_tree,
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 8".to_string(),
                err.message().to_string(),
            ))
        }
    };
    let local_tree = match local_tree.tree() {
        Ok(local_tree) => local_tree,
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 9".to_string(),
                err.message().to_string(),
            ))
        }
    };
    let ancestors = match repo.find_commit(repo.merge_base(local.id(), remote.id()).unwrap()) {
        Ok(ancestors) => ancestors,
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 10".to_string(),
                err.message().to_string(),
            ))
        }
    };
    let ancestors = match ancestors.tree() {
        Ok(ancestor) => ancestor,
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 11".to_string(),
                err.message().to_string(),
            ))
        }
    };
    let mut idx = match repo.merge_trees(&ancestors, &local_tree, &remote_tree, None) {
        Ok(idx) => idx,
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 12".to_string(),
                err.message().to_string(),
            ))
        }
    };
    if idx.has_conflicts() {
        debug_print!("{}", "Merge conflicts detected...");
        GitPushPullMessage {
            predefined_message: PredefinedMsg::None.into(),
            msg_index: 20,
            msg: "Merge conflicts detected...".to_string(),
        }
        .send_signal_to_dart();
        warn!("git_pull - normal_merge: Merge Conflicts Detected.");
        repo.checkout_index(Some(&mut idx), None).unwrap();
        return Ok(());
    }

    let oid = match idx.write_tree_to(repo) {
        Ok(oid) => oid,
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 13".to_string(),
                err.message().to_string(),
            ))
        }
    };
    let result_tree = match repo.find_tree(oid) {
        Ok(result_tree) => result_tree,
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 14".to_string(),
                err.message().to_string(),
            ))
        }
    };
    let return_msg = format!("Merge: {} into {}", remote.id(), local.id());
    let sig = Signature::now(&name, &email).unwrap();
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
                "git_pull - 15".to_string(),
                err.message().to_string(),
            ))
        }
    }
    match repo.checkout_head(None) {
        Ok(_) => {}
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 21".to_string(),
                err.message().to_string(),
            ))
        }
    };
    return Ok(());
}

fn do_merge<'a>(
    repo: &'a git2::Repository,
    remote_branch: String,
    fetch_commit: &'a git2::AnnotatedCommit,
    name: String,
    email: String,
) -> Result<(), GitError> {
    let analysis = match repo.merge_analysis(&[&fetch_commit]) {
        Ok(analysis) => analysis,
        Err(err) => {
            return Err(GitError::new(
                "git_pull - 19".to_string(),
                err.message().to_string(),
            ))
        }
    };
    if analysis.0.is_fast_forward() {
        info!("do_merge - remote_branch {}", remote_branch);
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
                return Ok(());
            }
        };
        match fast_forward(repo, &mut referance, &fetch_commit) {
            Ok(_) => {}
            Err(err) => return Err(err),
        };
    } else if analysis.0.is_normal() {
        let head_commit = repo
            .reference_to_annotated_commit(&repo.head().unwrap())
            .unwrap();
        match normal_merge(&repo, &head_commit, &fetch_commit, name, email) {
            Ok(_) => {}
            Err(err) => return Err(err),
        };
    } else if analysis.0.is_up_to_date() {
    }
    return Ok(());
}
