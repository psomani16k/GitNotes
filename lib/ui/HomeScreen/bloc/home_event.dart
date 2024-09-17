part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

// This event is added to bloc in the initState() function, initial event
final class HomeInitialEvent extends HomeEvent {}

// This event is added to bloc when the user selects a directory on the home screen
final class HomeChooseDirectoryItemEvent extends HomeEvent {
  final Directory item;
  HomeChooseDirectoryItemEvent(this.item);
}

// This event is added to bloc when the user selects a file on the home screen
final class HomeChooseFileItemEvent extends HomeEvent {}

final class HomeMakeNewFileEvent extends HomeEvent {
  final String fileName;
  final String extension;
  HomeMakeNewFileEvent(this.fileName, this.extension);
}
