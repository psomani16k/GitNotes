part of 'git_clone_bloc.dart';

@immutable
sealed class GitCloneState {}

final class GitCloneInitial extends GitCloneState {}
