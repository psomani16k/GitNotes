use std::{
    thread::sleep,
    time::{self, Duration, SystemTime},
};

use crate::{
    git_functions::{errors::git_errors::GitError, git_checkout::branch_repo::current_branch},
    messages::git_push_pull_messages::{GitPushPullMessage, PredefinedMsg},
};

use git2::{
    AnnotatedCommit, CertificateCheckStatus, Cred, DiffFormat, DiffOptions, Error, FetchOptions,
    Signature,
};

// 0 - 50
pub async fn git_pull(
    dir_path: String,
    password: Option<String>,
    email: String,
    name: String,
) -> Result<(), GitError> {
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
    let (fetch_annotated_commit, up_to_date) =
        match do_fetch(&repo, &b, &mut remote, email.clone(), password) {
            Ok(data) => data,
            Err(err) => {
                return Err(GitError::new(
                    "error during fetch in git pull".to_string(),
                    err.message().to_string(),
                ))
            }
        };

    if up_to_date {
        GitPushPullMessage {
            msg_index: 10000,
            predefined_message: PredefinedMsg::End.into(),
            msg: "".to_string(),
        }
        .send_signal_to_dart();
        return Ok(());
    }

    match do_merge(
        &repo,
        branch,
        &fetch_annotated_commit,
        name.clone(),
        email.clone(),
    ) {
        Ok(_) => {}
        Err(err) => {
            return Err(GitError::new(
                "error during merging in git pull".to_string(),
                err.message().to_string(),
            ))
        }
    };

    // end git pull
    GitPushPullMessage {
        msg_index: 10000,
        predefined_message: PredefinedMsg::End.into(),
        msg: "".to_string(),
    }
    .send_signal_to_dart();
    Ok(())
}

// 50 - 80
fn do_fetch<'a>(
    repo: &'a git2::Repository,
    refs: &'a Vec<String>,
    remote: &'a mut git2::Remote,
    user: String,
    pass: Option<String>,
) -> Result<(AnnotatedCommit<'a>, bool), Error> {
    let mut remote_cache = String::from("  ");
    let mut remote_msg_count = 50;

    let mut callback = git2::RemoteCallbacks::new();
    callback.certificate_check(|_, _| Ok(CertificateCheckStatus::CertificateOk));

    callback.credentials(|_a, _b, _c| match &pass {
        Some(pass) => Cred::userpass_plaintext(user.as_str(), pass.as_str()),
        None => Cred::username(user.as_str()),
    });

    callback.sideband_progress(|stats| {
        let stats = String::from_utf8_lossy(stats);
        let is_same = stats.starts_with(&remote_cache.clone());
        if !is_same {
            remote_msg_count += 1;
            let somthing: Vec<&str> = stats.split(" ").collect();
            remote_cache = somthing.first().unwrap().to_string();
        }
        let msg = format!("remote: {}", stats);
        let msg = msg.trim().to_string();
        GitPushPullMessage {
            predefined_message: PredefinedMsg::None.into(),
            msg_index: remote_msg_count,
            msg,
        }
        .send_signal_to_dart();
        sleep(Duration::from_millis(2));
        true
    });

    let mut transfer_helper = TransferProgressCallbackHelper::default();
    callback.transfer_progress(|stats| {
        transfer_helper.update(
            stats.received_objects(),
            stats.total_objects(),
            stats.received_bytes(),
        );

        true
    });
    let mut fetch_options = FetchOptions::new();
    fetch_options.remote_callbacks(callback);
    fetch_options.download_tags(git2::AutotagOption::All);
    remote.fetch(refs, Some(&mut fetch_options), None)?;
    let stats = remote.stats();
    let mut already_up_to_date = false;
    if stats.total_objects() == 0 {
        GitPushPullMessage {
            predefined_message: PredefinedMsg::None.into(),
            msg_index: 200,
            msg: "Already up to date.".to_string(),
        }
        .send_signal_to_dart();
        already_up_to_date = true;
    }
    let fetch_head = repo.find_reference("FETCH_HEAD")?;
    let annotated_commit = repo.reference_to_annotated_commit(&fetch_head)?;
    let msg = format!("From {}", remote.url().unwrap());
    GitPushPullMessage {
        predefined_message: PredefinedMsg::None.into(),
        msg_index: 65,
        msg,
    }
    .send_signal_to_dart();
    let head = repo.head().unwrap();
    let head_commit = repo.reference_to_annotated_commit(&head).unwrap();
    let head_commit_id = head_commit.id().to_string()[..7].to_string();
    let fetch_commit_id = annotated_commit.id().to_string()[..7].to_string();

    let local_branch = repo
        .find_branch(head.shorthand().unwrap(), git2::BranchType::Local)
        .unwrap();
    if let Ok(remote_branch) = local_branch.upstream() {
        let remote_name = remote_branch.name().unwrap_or(Some("FETCH_HEAD"));
        let remote_name = remote_name.unwrap();
        let msg = format!(
            "   {}..{}  {} -> {}",
            head_commit_id,
            fetch_commit_id,
            head.shorthand().unwrap(),
            remote_name
        );
        GitPushPullMessage {
            predefined_message: PredefinedMsg::None.into(),
            msg_index: 66,
            msg,
        }
        .send_signal_to_dart();
    }

    return Ok((annotated_commit, already_up_to_date));
}

// 100 - 150
fn do_merge<'a>(
    repo: &'a git2::Repository,
    remote_branch: String,
    fetch_commit: &'a git2::AnnotatedCommit,
    name: String,
    email: String,
) -> Result<(), Error> {
    let analysis = repo.merge_analysis(&[&fetch_commit])?;
    if analysis.0.is_fast_forward() {
        GitPushPullMessage {
            msg_index: 100,
            predefined_message: PredefinedMsg::None.into(),
            msg: "Fast-forward".to_string(),
        }
        .send_signal_to_dart();
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

        fast_forward(repo, &mut referance, &fetch_commit)?;
    } else if analysis.0.is_normal() {
        GitPushPullMessage {
            msg_index: 100,
            predefined_message: PredefinedMsg::None.into(),
            msg: "Normal-Merge".to_string(),
        }
        .send_signal_to_dart();
        let head_commit = repo
            .reference_to_annotated_commit(&repo.head().unwrap())
            .unwrap();
        match normal_merge(&repo, &head_commit, &fetch_commit, name, email) {
            Ok(_) => {}
            Err(err) => return Err(err),
        };
    }
    let new_commit = repo.find_commit(fetch_commit.id()).unwrap();
    let old_commit = repo.head().unwrap().peel_to_commit().unwrap();
    print_difference(repo, &old_commit, &new_commit)?;
    return Ok(());
}

fn fast_forward(
    repo: &git2::Repository,
    referance: &mut git2::Reference,
    fetch_commit: &git2::AnnotatedCommit,
    // TODO: return the string here and add a merge message to be shown to user
) -> Result<(), Error> {
    let name = match referance.name() {
        Some(name) => name.to_string(),
        None => String::from_utf8_lossy(referance.name_bytes()).to_string(),
    };
    let msg = format!(
        "Fast-Forward: Setting {} to id: {}",
        name,
        fetch_commit.id()
    );
    referance.set_target(fetch_commit.id(), &msg)?;
    repo.set_head(&name)?;
    repo.checkout_head(Some(git2::build::CheckoutBuilder::default().force()))?;
    return Ok(());
}

// 200 - 1000
fn print_difference(
    repo: &git2::Repository,
    old_commit: &git2::Commit,
    new_commit: &git2::Commit,
) -> Result<(), Error> {
    let old_tree = old_commit.tree()?;
    let new_tree = new_commit.tree()?;
    let diff = repo.diff_tree_to_tree(Some(&old_tree), Some(&new_tree), None)?;
    let diff_stats = diff.stats()?;

    GitPushPullMessage {
        msg_index: 101,
        predefined_message: PredefinedMsg::None.into(),
        msg: format!(
            " {} files changed, {} insertions(+), {} deletions(-)",
            diff_stats.files_changed(),
            diff_stats.insertions(),
            diff_stats.deletions()
        ),
    }
    .send_signal_to_dart();

    Ok(())
}

fn normal_merge(
    repo: &git2::Repository,
    local: &git2::AnnotatedCommit,
    remote: &git2::AnnotatedCommit,
    name: String,
    email: String,
) -> Result<(), Error> {
    let remote_tree = repo.find_commit(remote.id())?;
    let remote_tree = remote_tree.tree()?;
    let local_tree = repo.find_commit(local.id())?;
    let local_tree = local_tree.tree()?;
    let ancestors = repo.find_commit(repo.merge_base(local.id(), remote.id()).unwrap())?;
    let ancestors = ancestors.tree()?;
    let mut idx = repo.merge_trees(&ancestors, &local_tree, &remote_tree, None)?;
    if idx.has_conflicts() {
        GitPushPullMessage {
            predefined_message: PredefinedMsg::None.into(),
            msg_index: 20,
            msg: "Merge conflicts detected...".to_string(),
        };
        warn!("git_pull - normal_merge: Merge Conflicts Detected.");
        repo.checkout_index(Some(&mut idx), None).unwrap();
        return Ok(());
    }

    let oid = idx.write_tree_to(repo)?;
    let result_tree = repo.find_tree(oid)?;
    let reflog_msg = format!("Merge: {} into {}", remote.id(), local.id());
    let sig = Signature::now(&name, &email).unwrap();
    let local_commit = repo.find_commit(local.id()).unwrap();
    let remote_commit = repo.find_commit(remote.id()).unwrap();
    repo.commit(
        Some("HEAD"),
        &sig,
        &sig,
        &reflog_msg,
        &result_tree,
        &[&local_commit, &remote_commit],
    )?;
    repo.checkout_head(None)?;
    return Ok(());
}

struct TransferProgressCallbackHelper {
    last_update_time: SystemTime,
    last_transfered_bytes: usize,
}
impl Default for TransferProgressCallbackHelper {
    fn default() -> Self {
        return TransferProgressCallbackHelper {
            last_update_time: time::SystemTime::now(),
            last_transfered_bytes: 0,
        };
    }
}

impl TransferProgressCallbackHelper {
    fn update(&mut self, recieved_obj: usize, total_obj: usize, recieved_bytes: usize) {
        // this determines the update rate 200ms, should be fine
        let update_rate: u16 = 200;
        let now = time::SystemTime::now();
        if self
            .last_update_time
            .checked_add(Duration::from_millis(update_rate.try_into().unwrap()))
            .unwrap()
            > now
        {
            return;
        }

        let update_rate: usize = update_rate.try_into().unwrap();
        let bytes_per_sec = (recieved_bytes - self.last_transfered_bytes) * 1000 / update_rate;
        let (speed_num, speed_unit) = Self::give_speed(bytes_per_sec);
        let (transfer_num, transfer_unit) = Self::give_data_transfer(recieved_bytes);

        let complete_percent = 100 * recieved_obj / total_obj;

        let done = recieved_obj == total_obj;

        if done {
            let msg = format!("Unpacking objects: {complete_percent}% ({recieved_obj}/{total_obj}), {:.2} {transfer_unit} | {:.2} {speed_unit}, done.",transfer_num, speed_num );
            GitPushPullMessage {
                msg_index: 60,
                predefined_message: PredefinedMsg::None.into(),
                msg,
            }
            .send_signal_to_dart();
        } else {
            let msg = format!("Unpacking objects: {complete_percent}% ({recieved_obj}/{total_obj}), {:.2} {transfer_unit} | {:.2} {speed_unit}", transfer_num,speed_num);
            GitPushPullMessage {
                msg_index: 60,
                predefined_message: PredefinedMsg::None.into(),
                msg,
            }
            .send_signal_to_dart();
        }

        self.last_update_time = now;
        self.last_transfered_bytes = recieved_bytes;
    }

    fn give_speed(bytes_per_sec: usize) -> (f32, String) {
        // GiB/s
        if bytes_per_sec > 1_073_741_824 {
            let bytes_per_sec: f32 = bytes_per_sec as f32;
            let speed: f32 = bytes_per_sec / 1_073_741_824.0;
            return (speed, "GiB/s".to_string());
        // MiB/s
        } else if bytes_per_sec > 1_048_576 {
            let bytes_per_sec: f32 = bytes_per_sec as f32;
            let speed: f32 = bytes_per_sec / 1_048_576.0;
            return (speed, "MiB/s".to_string());
        // KiB/s
        } else if bytes_per_sec > 1_024 {
            let bytes_per_sec: f32 = bytes_per_sec as f32;
            let speed: f32 = bytes_per_sec / 1_024.0;
            return (speed, "KiB/s".to_string());
        }
        return (bytes_per_sec as f32, "B/s".to_string());
    }

    fn give_data_transfer(bytes_transfered: usize) -> (f32, String) {
        // gib/s
        if bytes_transfered > 1_073_741_824 {
            let bytes_transfered: f32 = bytes_transfered as f32;
            let data: f32 = bytes_transfered / 1_073_741_824.0;
            return (data, "Gib".to_string());
        // mib/s
        } else if bytes_transfered > 1_048_576 {
            let bytes_transfered: f32 = bytes_transfered as f32;
            let data: f32 = bytes_transfered / 1_048_576.0;
            return (data, "Mib".to_string());
        // kib/s
        } else if bytes_transfered > 1_024 {
            let bytes_transfered: f32 = bytes_transfered as f32;
            let data: f32 = bytes_transfered / 1_024.0;
            return (data, "Kib".to_string());
        }
        return (bytes_transfered as f32, "B".to_string());
    }
}
