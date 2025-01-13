part of 'git_clone_bloc.dart';

@immutable
sealed class GitCloneEvent {}

final class GitCloneAttemptCloneEvent extends GitCloneEvent {
  final String userName;
  final String userEmail;
  final String password;
  final String url;

  GitCloneAttemptCloneEvent({
    required this.userName,
    required this.userEmail,
    required this.password,
    required this.url,
  });
}

final class GitCloneReturnEvent extends GitCloneEvent {}
