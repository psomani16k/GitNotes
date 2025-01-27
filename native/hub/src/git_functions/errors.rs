pub mod git_errors {
    use std::fmt;

    use rinf::debug_print;

    #[derive(Clone, Debug)]
    pub struct GitError {
        message: String,
    }

    impl GitError {
        pub fn new(error_log_info: String, message: String) -> GitError {
            error!("ERROR_INFO: {}, ERROR: {}", error_log_info, message);
            debug_print!("ERROR_INFO: {}, ERROR: {}", error_log_info, message);
            GitError { message }
        }
    }

    impl fmt::Display for GitError {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            write!(f, "{}", self.message)
        }
    }
}
