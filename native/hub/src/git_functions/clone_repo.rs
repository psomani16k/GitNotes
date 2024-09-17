pub mod clone_repo {

    use git2::Cred;

    use crate::git_functions::errors::git_errors::GitError;

    use std::path::Path;

    pub fn clone_repo(
        url: &str,
        dir_path: String,
        password: Option<String>,
        user: Option<String>,
    ) -> Result<String, GitError> {
        let user = user.unwrap();
        let password = password.unwrap();
        let cred = Cred::userpass_plaintext(&user, &password);
        return Ok("()".to_owned());
    }
}
