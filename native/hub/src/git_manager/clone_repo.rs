use std::{error::Error, path::Path};

use gix::{clone::PrepareFetch, filter::plumbing::worktree};

fn clone_repo(url: String, dir_path: String) -> Result<bool, u128> {
    //debug_print!("{dir_path}");

    let dir_path = Path::new(&dir_path);

    let url = "https://github.com/psomani16k/Diraudio.git";

    unsafe {
        gix::interrupt::init_handler(1, || {});
    }

    let url = gix::url::parse(url.into()).unwrap();

    let url_scheme = url.clone().scheme;
    //debug_print!("Scheme: {}", url_scheme.as_str());

    let mut prepare_clone = gix::prepare_clone(url, dir_path).unwrap();

    let (mut prepare_checkout, _) = prepare_clone
        .fetch_then_checkout(gix::progress::Discard, &gix::interrupt::IS_INTERRUPTED)
        .unwrap();

    // debug_print!(
    //     "Checking out into {:?} ...",
    //     prepare_checkout.repo().work_dir().expect("should be there")
    // );

    let (repo, _) = prepare_checkout
        .main_worktree(gix::progress::Discard, &gix::interrupt::IS_INTERRUPTED)
        .unwrap();
    // debug_print!(
    //     "Repo cloned into {:?}",
    //     repo.work_dir().expect("directory pre-created")
    // );

    let remote = repo
        .find_default_remote(gix::remote::Direction::Fetch)
        .expect("always present after clone")
        .unwrap();

    // debug_print!(
    //     "Default remote: {} -> {}",
    //     remote
    //         .name()
    //         .expect("default remote is always named")
    //         .as_bstr(),
    //     remote
    //         .url(gix::remote::Direction::Fetch)
    //         .expect("should be the remote URL")
    //         .to_bstring(),
    // );

    Ok(true)
}
