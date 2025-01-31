part of 'home_directory_bloc.dart';

@immutable
abstract class HomeDirectoryEvent {}

// update the current repo and switch to its root directory
final class HomeDirectoryRepoUpdateEvent extends HomeDirectoryEvent {}

// set a new directory view
final class HomeDirectoryChooseDirectoryEvent extends HomeDirectoryEvent {
  final Directory dir;
  HomeDirectoryChooseDirectoryEvent({required this.dir});
}

// triggered when back key is pressed
final class HomeDirectoryBackPressEvent extends HomeDirectoryEvent {}

// updates the content of the current directory
final class HomeDirectoryUpdateDirectoryInfoEvent extends HomeDirectoryEvent {}
