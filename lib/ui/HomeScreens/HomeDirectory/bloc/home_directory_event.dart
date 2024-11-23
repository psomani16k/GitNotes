part of 'home_directory_bloc.dart';

@immutable
sealed class HomeDirectoryEvent {}

final class HomeDirectoryChooseEvent extends HomeDirectoryEvent {
  final Directory choosenDirectory;

  HomeDirectoryChooseEvent({required this.choosenDirectory});
}

final class HomeDirectoryFileEvent {
  final File choosenFile;

  HomeDirectoryFileEvent({required this.choosenFile});
}

final class HomeDirectoryBackEvent {}
