part of 'git_push_pull_bloc.dart';

@immutable
abstract class GitPushPullState {}

class GitPushPullInitial extends GitPushPullState {}

final class GitPushPullProcessingState extends GitPushPullState {}

final class GitPushPullUpdateActionsState extends GitPushPullState {
  final bool canPush;
  final bool canCommit;
  final bool repoExists;

  GitPushPullUpdateActionsState(
      {required this.canPush,
      required this.canCommit,
      required this.repoExists});
}

final class GitPushPullErrorState extends GitPushPullState {
  final String message;

  GitPushPullErrorState({required this.message});
}
