part of 'git_configuration_bloc.dart';

@immutable
sealed class GitConfigurationState {}

final class GitConfigurationInitial extends GitConfigurationState {}

final class GitConfigurationCloneLoadingState extends GitConfigurationState {}

final class GitConfigurationCloneFailState extends GitConfigurationState {
  final String error;
  GitConfigurationCloneFailState({required this.error});
}

final class GitConfigurationCloneSuccessState extends GitConfigurationState {
  final String repoName;
  GitConfigurationCloneSuccessState({required this.repoName});
}
