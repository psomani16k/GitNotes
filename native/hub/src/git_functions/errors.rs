pub mod git_errors {
    use std::fmt;

    #[derive(Clone, Debug)]
    pub struct GitError {
        message: String,
    }

    impl GitError {
        pub fn new(message: String) -> GitError {
            GitError { message }
        }
    }

    impl fmt::Display for GitError {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            write!(f, "ERROR: {}", self.message)
        }
    }
}
