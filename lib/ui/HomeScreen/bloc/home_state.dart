part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

// This state carries the initial state of the homescreen
final class HomeInitial extends HomeState {}

// This state carries the files to be displayed on the main screen
final class HomeSetDirectoryViewState extends HomeState {
  final List<File> fileItems;
  final List<Directory> directoryItems;

  HomeSetDirectoryViewState(this.fileItems, this.directoryItems);
}

final class HomeConfigureGitState extends HomeState {}

final class HomeSetLoadingState extends HomeState {
  final String message;
  HomeSetLoadingState(this.message);
}

final class HomeErrorState extends HomeState {
  String message;
  HomeErrorState(this.message);
}
