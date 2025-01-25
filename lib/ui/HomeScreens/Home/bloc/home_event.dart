part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

final class HomeChooseRepositoryEvent extends HomeEvent {
  final GitRepo repo;

  HomeChooseRepositoryEvent({required this.repo});
}

final class HomeNewRepositoryClonedEvent extends HomeEvent {
  final GitRepo newRepo;

  HomeNewRepositoryClonedEvent({required this.newRepo});
}
