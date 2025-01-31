part of 'home_git_bloc.dart';

@immutable
abstract class HomeGitState {}

final class HomeGitInitial extends HomeGitState {}

// carries git status information and sets status loading to false
final class HomeGitInitialState extends HomeGitState {
  final List<FileStatusData>? staged;
  final List<FileStatusData>? changed;

  HomeGitInitialState({this.staged, this.changed});
}

// carries git status information and sets status loading to false
final class HomeGitRepoUpdateState extends HomeGitState {
  final List<FileStatusData> staged;
  final List<FileStatusData> changed;

  HomeGitRepoUpdateState({required this.staged, required this.changed});
}

// carries git status information and sets stage loading to false
final class HomeGitUpdateViewState extends HomeGitState {
  final List<FileStatusData> staged;
  final List<FileStatusData> changed;

  HomeGitUpdateViewState({required this.staged, required this.changed});
}

// tells the screen to show that the request is being processed
final class HomeGitAddRemoveProcessingState extends HomeGitState {}

// tells the screen to show the repo was updated and status is being brought in
final class HomeGitRepoChangeProcessingState extends HomeGitState {}

// display some error that may have occured...
final class HomeGitHardErrorState extends HomeGitState {
  final String message;

  HomeGitHardErrorState({required this.message});
}

// show a snackbar of a soft error
final class HomeGitSoftErrorState extends HomeGitState {
  final String message;

  HomeGitSoftErrorState({required this.message});
}
