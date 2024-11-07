part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

// This event is added to bloc in the initState() function, initial event
final class HomeInitialEvent extends HomeEvent {}

// This event is added to bloc when the user wants to choose another repo for browsing
final class HomeChooseRepoEvent extends HomeEvent {
  final GitRepo choosenRepo;
  HomeChooseRepoEvent(this.choosenRepo);
}

// This event is triggered when the user chooses a directory to browse
final class HomeChooseDirectoryEvent extends HomeEvent {
  final Directory dir;
  HomeChooseDirectoryEvent(this.dir);
}

final class HomeUpdateRepoEntitiesEvent extends HomeEvent {}

final class HomeBackPressEvent extends HomeEvent {}

final class HomeSinglePullEvent extends HomeEvent {}
