import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:git_notes/helpers/git/git_repo.dart';
import 'package:git_notes/helpers/git/git_repo_manager.dart';
import 'package:meta/meta.dart';

part 'home_directory_event.dart';
part 'home_directory_state.dart';

class HomeDirectoryBloc extends Bloc<HomeDirectoryEvent, HomeDirectoryState> {
  HomeDirectoryBloc() : super(HomeDirectoryInitial()) {
    GitRepo? currentRepo;
    Directory? currentDirectory;
    bool shouldExit = false;

    on<HomeDirectoryEvent>((event, emit) {});

    on<HomeDirectoryRepoUpdateEvent>((event, emit) {
      currentRepo = GitRepoManager.getInstance().getRepo();
      if (currentRepo == null) {
        emit(HomeDirectorySetDirectoryState(
            fileEntities: null, directoryEntities: null, reverse: false));
        return;
      }
      currentDirectory = currentRepo!.getDirectory();
      List<File> fileEntities = [];
      List<Directory> directoryEntities = [];
      List<FileSystemEntity> fileSystemEntities = currentDirectory!.listSync();

      for (FileSystemEntity fileSystemEntity in fileSystemEntities) {
        if (fileSystemEntity is File) {
          fileEntities.add(fileSystemEntity);
        } else if (fileSystemEntity is Directory) {
          directoryEntities.add(fileSystemEntity);
        }
      }

      emit(HomeDirectorySetDirectoryState(
        currentDirectory: currentDirectory,
        fileEntities: fileEntities,
        directoryEntities: directoryEntities,
        reverse: false,
      ));
    });

    on<HomeDirectoryChooseDirectoryEvent>(
      (event, emit) {
        currentDirectory = event.dir;

        List<File> fileEntities = [];
        List<Directory> directoryEntities = [];
        List<FileSystemEntity> fileSystemEntities =
            currentDirectory!.listSync();

        for (FileSystemEntity fileSystemEntity in fileSystemEntities) {
          if (fileSystemEntity is File) {
            fileEntities.add(fileSystemEntity);
          } else if (fileSystemEntity is Directory) {
            directoryEntities.add(fileSystemEntity);
          }
        }

        emit(HomeDirectorySetDirectoryState(
          currentDirectory: currentDirectory,
          fileEntities: fileEntities,
          directoryEntities: directoryEntities,
          reverse: false,
        ));
      },
    );

    on<HomeDirectoryBackPressEvent>(
      (event, emit) {
        if (shouldExit) {
          emit(HomeDirectoryExitAppState());
          return;
        }
        if (currentDirectory?.path == currentRepo?.getDirectory().path) {
          emit(HomeDirectoryShowSnackbarState(message: "Press again to exit."));
          shouldExit = true;
        } else {
          shouldExit = false;

          currentDirectory = currentDirectory!.parent;
          List<File> fileEntities = [];
          List<Directory> directoryEntities = [];
          List<FileSystemEntity> fileSystemEntities =
              currentDirectory!.listSync();

          for (FileSystemEntity fileSystemEntity in fileSystemEntities) {
            if (fileSystemEntity is File) {
              fileEntities.add(fileSystemEntity);
            } else if (fileSystemEntity is Directory) {
              directoryEntities.add(fileSystemEntity);
            }
          }
          emit(HomeDirectorySetDirectoryState(
            currentDirectory: currentDirectory,
            fileEntities: fileEntities,
            directoryEntities: directoryEntities,
            reverse: true,
          ));
        }
      },
    );

    on<HomeDirectoryUpdateDirectoryInfoEvent>(
      (event, emit) {
        List<File> fileEntities = [];
        List<Directory> directoryEntities = [];
        List<FileSystemEntity> fileSystemEntities =
            currentDirectory!.listSync();

        for (FileSystemEntity fileSystemEntity in fileSystemEntities) {
          if (fileSystemEntity is File) {
            fileEntities.add(fileSystemEntity);
          } else if (fileSystemEntity is Directory) {
            directoryEntities.add(fileSystemEntity);
          }
        }

        emit(HomeDirectorySetDirectoryState(
          currentDirectory: currentDirectory,
          fileEntities: fileEntities,
          directoryEntities: directoryEntities,
          reverse: false,
        ));
      },
    );
  }
}
