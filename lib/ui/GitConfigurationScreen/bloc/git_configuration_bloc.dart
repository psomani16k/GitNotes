import 'package:bloc/bloc.dart';
import 'package:git_notes/helpers/git/git_repo.dart';
import 'package:git_notes/messages/clone.pb.dart';
import 'package:meta/meta.dart';

part 'git_configuration_event.dart';
part 'git_configuration_state.dart';

class GitConfigurationBloc
    extends Bloc<GitConfigurationEvent, GitConfigurationState> {
  GitConfigurationBloc() : super(GitConfigurationInitial()) {
    on<GitConfigurationCloneRepoEvent>(
      (event, emit) async {
        // Create GitRepo
        GitRepo repo = GitRepo(event.url, event.userName);
        repo.setPassword(event.authCode);

        // Emit loading state
        emit(GitConfigurationCloneLoadingState());

        // initiate clone and wait for result
        CloneCallback callBack = await repo.cloneAndSaveRepo();

        // emit result state accordingly
        if (callBack.status == CloneResult.Fail) {
          emit(GitConfigurationCloneFailState(error: callBack.data));
        } else {
          emit(GitConfigurationCloneSuccessState(
              repoName: "Repository ID: ${callBack.data}"));
        }
      },
    );
  }
}
