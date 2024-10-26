part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

// This state carries the initial state of the homescreen
final class HomeInitialState extends HomeState {
  final List<GitRepo> repoEntities;
  final List<Directory> directoryEntities;
  final List<File> fileEntities;
  final GitRepo initialRepo;
  HomeInitialState(
      {required this.repoEntities,
      required this.directoryEntities,
      required this.fileEntities,
      required this.initialRepo});
}

// This state is emitted when the user has no repos to display
final class HomeNoRepoState extends HomeState {}

// This state carries the update currentRepo when the user chooses a new repo
final class HomeUpdateCurrentRepoState extends HomeState {
  final GitRepo newRepo;
  final List<Directory> directoryEntities;
  final List<File> fileEntities;
  HomeUpdateCurrentRepoState(
      this.directoryEntities, this.fileEntities, this.newRepo);
}

// This state has the files and directory of a selected directory
final class HomeUpdateDirectoryState extends HomeState {
  final List<Directory> directoryEntities;
  final List<File> fileEntities;
  HomeUpdateDirectoryState(this.directoryEntities, this.fileEntities);
}
