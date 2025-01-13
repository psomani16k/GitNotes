part of 'git_clone_bloc.dart';

@immutable
sealed class GitCloneState {}

final class GitCloneInitial extends GitCloneState {}

final class GitCloneInitialState extends GitCloneState {
  final String? defaultName;
  final String? defaultEmail;
  final String? defaultId;

  GitCloneInitialState({
    this.defaultName,
    this.defaultEmail,
    this.defaultId,
  });
}

final class GitCloneLoadingState extends GitCloneState {}

final class GitCloneSuccessState extends GitCloneState {
  final String path;

  GitCloneSuccessState({required this.path});
}

final class GitCloneFailState extends GitCloneState {
  final String error;

  GitCloneFailState({required this.error});
}

final class GitCloneReturnState extends GitCloneState {}
