import 'package:bloc/bloc.dart';
import 'package:git_notes/helpers/git/git_repo_manager.dart';
import 'package:git_notes/messages/commit_push_check.pbserver.dart';
import 'package:git_notes/messages/git_commit.pb.dart';
import 'package:git_notes/messages/git_pull.pb.dart';
import 'package:git_notes/messages/git_push.pb.dart';
import 'package:meta/meta.dart';

part 'git_push_pull_event.dart';
part 'git_push_pull_state.dart';

class GitPushPullBloc extends Bloc<GitPushPullEvent, GitPushPullState> {
  GitPushPullBloc() : super(GitPushPullInitial()) {
    on<GitPushPullEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<GitPushPullUpdateEvent>(
      (event, emit) async {
        emit(GitPushPullProcessingState());
        CommitAndPushCheckCallback? checkCallback =
            await GitRepoManager.getInstance().checkCommitAndPush();

        if (checkCallback == null) {
          emit(GitPushPullUpdateActionsState(
            canPush: false,
            canCommit: false,
            repoExists: false,
          ));
        } else {
          emit(GitPushPullUpdateActionsState(
            canPush: checkCallback.pushAllowed,
            canCommit: checkCallback.commitAllowed,
            repoExists: true,
          ));
        }
      },
    );

    on<GitPushPullPerformCommitEvent>(
      (event, emit) async {
        emit(GitPushPullProcessingState());
        // TODO: use a default message here
        String defaultMessage = "Commit from GitNotes";
        GitCommitCallback? callback = await GitRepoManager.getInstance()
            .commit(event.message ?? defaultMessage);
        if (callback!.result == GitCommitResult.Fail) {
          emit(GitPushPullErrorState(message: "Could not commit"));
        } else {
          CommitAndPushCheckCallback? checkCallback =
              await GitRepoManager.getInstance().checkCommitAndPush();
          emit(GitPushPullUpdateActionsState(
            canPush: checkCallback!.pushAllowed,
            canCommit: checkCallback.commitAllowed,
            repoExists: true,
          ));
        }
      },
    );

    on<GitPushPullPerformPullEvent>(
      (event, emit) async {
        // enter processing state
        emit(GitPushPullProcessingState());

        // perform pull
        GitPullSingleCallback? callback =
            await GitRepoManager.getInstance().pull();

        // check for errors
        if (callback!.status == GitPullResult.Fail) {
          emit(GitPushPullErrorState(message: "Failed to perform pull"));
        } else {
          // TODO: remove this and let the terminal like interface give live updates
          emit(GitPushPullErrorState(message: "Pulled Successfully"));

          // if no errors then update the page
          CommitAndPushCheckCallback? checkCallback =
              await GitRepoManager.getInstance().checkCommitAndPush();
          emit(GitPushPullUpdateActionsState(
            canPush: checkCallback!.pushAllowed,
            canCommit: checkCallback.commitAllowed,
            repoExists: true,
          ));
        }
      },
    );

    on<GitPushPullPerformPushEvent>(
      (event, emit) async {
        // enter processing state
        emit(GitPushPullProcessingState());

        // perform push
        GitPushCallback? callback = await GitRepoManager.getInstance().push();

        // check for errors
        if (callback!.result == GitPushResult.Fail) {
          emit(GitPushPullErrorState(message: "Failed to perform push"));
        } else {
          // TODO: remove this and let the terminal like interface give live updates
          emit(GitPushPullErrorState(message: "Pushed Successfully"));

          // if no errors then update the page
          CommitAndPushCheckCallback? checkCallback =
              await GitRepoManager.getInstance().checkCommitAndPush();
          emit(GitPushPullUpdateActionsState(
            canPush: checkCallback!.pushAllowed,
            canCommit: checkCallback.commitAllowed,
            repoExists: true,
          ));
        }
      },
    );
  }
}
