part of 'home_git_bloc.dart';

@immutable
abstract class HomeGitEvent {}

// initiate the whole thing
final class HomeGitInitialEvent extends HomeGitEvent {}

// send status loading as true and update the repo and view
final class HomeGitRepoUpdateEvent extends HomeGitEvent {}

// send stage loading as true and update the view
final class HomeGitUpdateViewEvent extends HomeGitEvent {}

// send out stage loading true and refuse all other such requests
final class HomeGitStageFileEvent extends HomeGitEvent {
  final String relativeFilePath;
  HomeGitStageFileEvent({required this.relativeFilePath});
}

// send out stage loading true and refuse all other such requests
final class HomeGitUnstageFileEvent extends HomeGitEvent {
  final String relativeFilePath;
  HomeGitUnstageFileEvent({required this.relativeFilePath});
}

// send out stage loading true and refuse all other such requests
final class HomeGitRestoreFileEvent extends HomeGitEvent {
  final String relativeFilePath;
  HomeGitRestoreFileEvent({required this.relativeFilePath});
}
