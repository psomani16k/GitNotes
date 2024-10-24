part of 'git_configuration_bloc.dart';

@immutable
sealed class GitConfigurationEvent {}

final class GitConfigurationInitialEvent extends GitConfigurationEvent {}

@immutable
final class GitConfigurationCloneRepoEvent extends GitConfigurationEvent {
  final String userName;
  final String url;
  final String? authCode;
  GitConfigurationCloneRepoEvent(
      {required this.url, required this.userName, this.authCode});
}
