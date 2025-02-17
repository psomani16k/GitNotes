part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeSetRepositoryState extends HomeState {
  final GitRepo? repo;

  HomeSetRepositoryState({required this.repo});
}
