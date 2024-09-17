part of 'git_configuration_bloc.dart';

@immutable
sealed class GitConfigurationEvent {}

final class GitConfigurationInitialEvent extends GitConfigurationEvent {}
