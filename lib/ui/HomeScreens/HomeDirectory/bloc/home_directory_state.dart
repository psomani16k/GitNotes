part of 'home_directory_bloc.dart';

@immutable
abstract class HomeDirectoryState {}

class HomeDirectoryInitial extends HomeDirectoryState {}

// sets the dirs and files to be displayed
final class HomeDirectorySetDirectoryState extends HomeDirectoryState {
  final List<Directory>? directoryEntities;
  final List<File>? fileEntities;
  final bool reverse;
  final Directory? currentDirectory;

  HomeDirectorySetDirectoryState(
      {this.directoryEntities,
      this.currentDirectory,
      this.fileEntities,
      required this.reverse});
}

// asks the app to be exited
final class HomeDirectoryExitAppState extends HomeDirectoryState {}

// shows a snackbar with the given message
final class HomeDirectoryShowSnackbarState extends HomeDirectoryState {
  final String message;

  HomeDirectoryShowSnackbarState({required this.message});
}
