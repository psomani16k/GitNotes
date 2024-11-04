pub mod git_errors {
    use std::fmt;

    use rinf::debug_print;

    #[derive(Clone, Debug)]
    pub struct GitError {
        message: String,
    }

    impl GitError {
        pub fn new(error_code: String, message: String) -> GitError {
            debug_print!("ERROR_CODE: {}, ERROR: {}", error_code, message);
            GitError { message }
        }
    }

    impl fmt::Display for GitError {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            write!(f, "ERROR: {}", self.message)
        }
    }
}
