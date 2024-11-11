pub mod status {
    use git2::{Error, Repository, StatusOptions};

    pub fn get_status(path: String) -> Result<Vec<String>, Error> {
        let repo = Repository::open(&path)?;
        if repo.is_bare() {
            return Err(Error::from_str("cannot report status on bare repository"));
        }

        let mut opts = StatusOptions::new();
        opts.include_ignored(false);
        opts.include_untracked(true).recurse_untracked_dirs(true);
        opts.exclude_submodules(true);

        let statuses = repo.statuses(Some(&mut opts)).unwrap();
        return Ok(show_status(&statuses));
    }

    fn show_status(statuses: &git2::Statuses) -> Vec<String> {
        let mut return_string: Vec<String> = Vec::new();
        for entry in statuses.iter() {
            let status_string = match entry.status() {
                s if s.contains(git2::Status::WT_NEW) => "WN",
                s if s.contains(git2::Status::WT_MODIFIED) => "WM",
                s if s.contains(git2::Status::WT_DELETED) => "WD",
                s if s.contains(git2::Status::WT_RENAMED) => "WR",
                s if s.contains(git2::Status::WT_TYPECHANGE) => "WT",
                s if s.contains(git2::Status::INDEX_NEW) => "IN",
                s if s.contains(git2::Status::INDEX_MODIFIED) => "IM",
                s if s.contains(git2::Status::INDEX_DELETED) => "ID",
                s if s.contains(git2::Status::INDEX_RENAMED) => "IR",
                s if s.contains(git2::Status::INDEX_TYPECHANGE) => "IT",
                _ => {
                    continue;
                }
            };
            let status_string = format!("{}_{}\n", status_string, entry.path().unwrap());
            return_string.push(status_string);
        }
        return return_string;
    }
}
