part of 'git_push_pull_bloc.dart';

@immutable
abstract class GitPushPullEvent {}

final class GitPushPullUpdateEvent extends GitPushPullEvent {}

final class GitPushPullPerformCommitEvent extends GitPushPullEvent {
  final String? message;
  GitPushPullPerformCommitEvent({this.message});
}

final class GitPushPullPerformPullEvent extends GitPushPullEvent {}

final class GitPushPullPerformPushEvent extends GitPushPullEvent {}

