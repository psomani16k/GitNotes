import 'package:bloc/bloc.dart';
import 'package:git_notes/helpers/git/git_repo_manager.dart';
import 'package:git_notes/messages/git_clone.pb.dart';
import 'package:meta/meta.dart';

part 'git_clone_event.dart';
part 'git_clone_state.dart';

class GitCloneBloc extends Bloc<GitCloneEvent, GitCloneState> {
  GitCloneBloc() : super(GitCloneInitial()) {
    on<GitCloneAttemptCloneEvent>((event, emit) async {
      emit(GitCloneLoadingState());
      GitCloneCallback callback = await GitRepoManager.getInstance().clone(
        event.userName,
        event.userEmail,
        event.url,
        event.password,
      );
      if (callback.status == GitCloneResult.Success) {
        String path = callback.data;
        emit(GitCloneSuccessState(path: path));
      } else {
        String error = callback.data;
        emit(GitCloneFailState(error: error));
      }
    });

    on<GitCloneReturnEvent>((event, emit) {
      emit(GitCloneReturnState());
    });
  }
}
