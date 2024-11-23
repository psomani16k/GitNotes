part of 'home_directory_bloc.dart';

@immutable
sealed class HomeDirectoryState {}

final class HomeDirectoryInitial extends HomeDirectoryState {}

final class HomeDirectorySetDirectoryEvent extends HomeDirectoryState {
  final List<File> fileEntities;
  final List<Directory> directoryEntities;

  HomeDirectorySetDirectoryEvent(
      {required this.fileEntities, required this.directoryEntities});
}
