part of 'git_configuration_bloc.dart';

@immutable
sealed class GitConfigurationState {}

final class GitConfigurationInitial extends GitConfigurationState {}
