pub mod git_errors {
    use std::fmt;

    #[derive(Clone, Debug)]
    pub struct CloneError {
        message: String,
    }

    impl CloneError {
        pub fn new(message: String) -> CloneError {
            CloneError { message }
        }
    }

    impl fmt::Display for CloneError {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            write!(f, "ERROR IN CLONING: {}", self.message)
        }
    }
}
