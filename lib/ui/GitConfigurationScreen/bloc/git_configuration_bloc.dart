import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'git_configuration_event.dart';
part 'git_configuration_state.dart';

class GitConfigurationBloc extends Bloc<GitConfigurationEvent, GitConfigurationState> {
  GitConfigurationBloc() : super(GitConfigurationInitial()) {
    on<GitConfigurationEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
