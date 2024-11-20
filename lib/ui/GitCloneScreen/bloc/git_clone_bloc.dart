import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'git_clone_event.dart';
part 'git_clone_state.dart';

class GitCloneBloc extends Bloc<GitCloneEvent, GitCloneState> {
  GitCloneBloc() : super(GitCloneInitial()) {
    on<GitCloneEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
