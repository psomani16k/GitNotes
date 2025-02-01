import 'package:bloc/bloc.dart';
import 'package:git_notes/helpers/git/git_repo_manager.dart';
import 'package:git_notes/messages/git_add.pbserver.dart';
import 'package:git_notes/messages/git_restore.pb.dart';
import 'package:git_notes/messages/git_status.pb.dart';
import 'package:git_notes/ui/HomeScreens/HomeGit/model/home_git_model.dart';
import 'package:meta/meta.dart';

part 'home_git_event.dart';
part 'home_git_state.dart';

class HomeGitBloc extends Bloc<HomeGitEvent, HomeGitState> {
  HomeGitBloc() : super(HomeGitInitial()) {
    bool statusProcessing = false;

    on<HomeGitEvent>((event, emit) {});

    on<HomeGitInitialEvent>(
      (event, emit) async {
        emit(HomeGitRepoChangeProcessingState());
        // get the status of the new repo
        GitStatusCallback? statusCallback =
            await GitRepoManager.getInstance().status();

        // if status is error, we emit error state and return
        if (statusCallback == null) {
          emit(HomeGitInitialState());
          return;
        }

        // organise it
        List<GitFileStatus> fileStatuses = statusCallback.fileStatuses;
        List<FileStatusData> staged = [];
        List<FileStatusData> changed = [];

        for (GitFileStatus status in fileStatuses) {
          FileStatusData statusData = FileStatusData(status);
          if (statusData.staged) {
            staged.add(statusData);
          } else {
            changed.add(statusData);
          }
        }

        // emit HomeGitInitialState
        emit(HomeGitInitialState(staged: staged, changed: changed));
      },
    );

    on<HomeGitRepoUpdateEvent>((event, emit) async {
      // emit HomeGitRepoChangeProcessingState
      emit(HomeGitRepoChangeProcessingState());

      // get the status of the new repo
      GitStatusCallback? statusCallback =
          await GitRepoManager.getInstance().status();

      // if status is error, we emit error state and return
      if (statusCallback!.result == GitStatusResult.Fail) {
        emit(HomeGitHardErrorState(
            message:
                "Error occured while getting repository status: ${statusCallback.failureMessage}"));
        return;
      }

      // organise it
      List<GitFileStatus> fileStatuses = statusCallback.fileStatuses;
      List<FileStatusData> staged = [];
      List<FileStatusData> changed = [];

      for (GitFileStatus status in fileStatuses) {
        FileStatusData statusData = FileStatusData(status);
        if (statusData.staged) {
          staged.add(statusData);
        } else {
          changed.add(statusData);
        }
      }

      // emit HomeGitRepoUpdateState
      emit(HomeGitRepoUpdateState(staged: staged, changed: changed));
    });

    on<HomeGitUpdateViewEvent>(
      (event, emit) async {
        // if statusProcessing is true, return
        if (statusProcessing) return;

        // emit HomeGitAddRemoveProcessingState
        emit(HomeGitAddRemoveProcessingState());

        // set statusProcessing to true
        statusProcessing = true;

        // get the new status
        GitStatusCallback? statusCallback =
            await GitRepoManager.getInstance().status();

        // if status is error, we emit error state and return
        if (statusCallback!.result == GitStatusResult.Fail) {
          statusProcessing = false;
          emit(HomeGitHardErrorState(
              message:
                  "Error occured while getting repository status: ${statusCallback.failureMessage}"));
          return;
        }

        // organise it
        List<GitFileStatus> fileStatuses = statusCallback.fileStatuses;
        List<FileStatusData> staged = [];
        List<FileStatusData> changed = [];

        for (GitFileStatus status in fileStatuses) {
          FileStatusData statusData = FileStatusData(status);
          if (statusData.staged) {
            staged.add(statusData);
          } else {
            changed.add(statusData);
          }
        }

        // emit HomeGitUpdateViewEvent
        emit(HomeGitUpdateViewState(staged: staged, changed: changed));

        // set statusProcessing to false
        statusProcessing = false;
      },
    );

    on<HomeGitStageFileEvent>(
      (event, emit) async {
        // if statusProcessing is true, return
        if (statusProcessing) return;

        // emit HomeGitAddRemoveProcessingState
        emit(HomeGitAddRemoveProcessingState());

        // set statusProcessing to true
        statusProcessing = true;

        // stage the file
        GitAddCallback? addCallback =
            await GitRepoManager.getInstance().stage(event.relativeFilePath);
        if (addCallback!.result == GitAddResult.Fail) {
          emit(HomeGitSoftErrorState(message: "Could not stage file."));
        }

        // get the new status
        GitStatusCallback? statusCallback =
            await GitRepoManager.getInstance().status();

        // if status is error, we emit error state and return
        if (statusCallback!.result == GitStatusResult.Fail) {
          statusProcessing = false;
          emit(HomeGitSoftErrorState(
              message:
                  "Error occured while getting repository status: ${statusCallback.failureMessage}"));
          return;
        }

        // organise it
        List<GitFileStatus> fileStatuses = statusCallback.fileStatuses;
        List<FileStatusData> staged = [];
        List<FileStatusData> changed = [];

        for (GitFileStatus status in fileStatuses) {
          FileStatusData statusData = FileStatusData(status);
          if (statusData.staged) {
            staged.add(statusData);
          } else {
            changed.add(statusData);
          }
        }

        // emit HomeGitUpdateViewEvent
        emit(HomeGitUpdateViewState(staged: staged, changed: changed));

        // set statusProcessing to false
        statusProcessing = false;
      },
    );

    on<HomeGitUnstageFileEvent>(
      (event, emit) async {
        // if statusProcessing is true, return
        if (statusProcessing) return;

        // emit HomeGitAddRemoveProcessingState
        emit(HomeGitAddRemoveProcessingState());

        // set statusProcessing to true
        statusProcessing = true;

        // unstage the file
        GitRemoveCallback? removeCallback =
            await GitRepoManager.getInstance().unstage(event.relativeFilePath);
        if (removeCallback!.result == GitAddResult.Fail) {
          emit(HomeGitSoftErrorState(
              message: "Could not remove file from stage."));
        }

        // get the new status
        GitStatusCallback? statusCallback =
            await GitRepoManager.getInstance().status();

        // if status is error, we emit error state and return
        if (statusCallback!.result == GitStatusResult.Fail) {
          statusProcessing = false;
          emit(HomeGitSoftErrorState(
              message:
                  "Error occured while getting repository status: ${statusCallback.failureMessage}"));
          return;
        }

        // organise it
        List<GitFileStatus> fileStatuses = statusCallback.fileStatuses;
        List<FileStatusData> staged = [];
        List<FileStatusData> changed = [];

        for (GitFileStatus status in fileStatuses) {
          FileStatusData statusData = FileStatusData(status);
          if (statusData.staged) {
            staged.add(statusData);
          } else {
            changed.add(statusData);
          }
        }

        // emit HomeGitUpdateViewEvent
        emit(HomeGitUpdateViewState(staged: staged, changed: changed));

        // set statusProcessing to false
        statusProcessing = false;
      },
    );

    on<HomeGitRestoreFileEvent>(
      (event, emit) async {
        // if statusProcessing is true, return
        if (statusProcessing) return;

        // emit HomeGitAddRemoveProcessingState
        emit(HomeGitAddRemoveProcessingState());

        // set statusProcessing to true
        statusProcessing = true;

        // unstage the file
        GitRestoreCallback? restoreCallback =
            await GitRepoManager.getInstance().restore(event.relativeFilePath);
        if (restoreCallback!.result == GitRestoreResult.Fail) {
          emit(HomeGitSoftErrorState(message: "Could not restore file."));
        }

        // get the new status
        GitStatusCallback? statusCallback =
            await GitRepoManager.getInstance().status();

        // if status is error, we emit error state and return
        if (statusCallback!.result == GitStatusResult.Fail) {
          statusProcessing = false;
          emit(HomeGitSoftErrorState(
              message:
                  "Error occured while getting repository status: ${statusCallback.failureMessage}"));
          return;
        }

        // organise it
        List<GitFileStatus> fileStatuses = statusCallback.fileStatuses;
        List<FileStatusData> staged = [];
        List<FileStatusData> changed = [];

        for (GitFileStatus status in fileStatuses) {
          FileStatusData statusData = FileStatusData(status);
          if (statusData.staged) {
            staged.add(statusData);
          } else {
            changed.add(statusData);
          }
        }

        // emit HomeGitUpdateViewEvent
        emit(HomeGitUpdateViewState(staged: staged, changed: changed));

        // set statusProcessing to false
        statusProcessing = false;
      },
    );
  }
}
