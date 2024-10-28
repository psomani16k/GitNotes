import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:git_notes/helpers/git/git_repo.dart';
import 'package:git_notes/helpers/git/repo_storage.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  RepoStorage? repoStorage;

  GitRepo? selectedRepo;

  Directory? currentDirectory;

  HomeBloc() : super(HomeInitial()) {
    on<HomeInitialEvent>(
      (event, emit) async {
        repoStorage ??= await RepoStorage.getInstance();
        List<GitRepo> repoEntities = repoStorage!.getAllRepos();
        if (repoEntities.isEmpty) {
          emit(HomeNoRepoState());
        } else {
          selectedRepo = repoEntities.first;
          currentDirectory = selectedRepo!.getDirectory();
          // this directory will exist if the repos exists...
          List<FileSystemEntity> directoryEntity =
              await currentDirectory!.list().toList();
          List<File> fileEntities = [];
          List<Directory> directoryEntities = [];
          for (FileSystemEntity element in directoryEntity) {
            if (element is File) {
              fileEntities.add(element);
            } else if (element is Directory) {
              directoryEntities.add(element);
            }
          }
          emit(
            HomeInitialState(
                repoEntities: repoEntities,
                directoryEntities: directoryEntities,
                fileEntities: fileEntities,
                initialRepo: selectedRepo!),
          );
        }
      },
    );

    on<HomeChooseRepoEvent>(
      (event, emit) async {
        selectedRepo = event.choosenRepo;
        currentDirectory = selectedRepo!.getDirectory();
        List<FileSystemEntity> directoryEntity =
            await currentDirectory!.list().toList();
        List<File> fileEntities = [];
        List<Directory> directoryEntities = [];
        for (FileSystemEntity element in directoryEntity) {
          if (element is File) {
            fileEntities.add(element);
          } else if (element is Directory) {
            directoryEntities.add(element);
          }
        }
        emit(HomeUpdateCurrentRepoState(
            directoryEntities, fileEntities, selectedRepo!));
      },
    );

    on<HomeChooseDirectoryEvent>(
      (event, emit) async {
        currentDirectory = event.dir;
        List<FileSystemEntity> directoryEntity =
            await event.dir.list().toList();
        List<File> fileEntities = [];
        List<Directory> directoryEntities = [];
        for (FileSystemEntity element in directoryEntity) {
          if (element is File) {
            fileEntities.add(element);
          } else if (element is Directory) {
            directoryEntities.add(element);
          }
        }
        emit(HomeTriggerAnimationState());
        await Future.delayed(Durations.medium1);
        emit(HomeUpdateDirectoryState(directoryEntities, fileEntities));
      },
    );

    on<HomeUpdateRepoEntitiesEvent>(
      (event, emit) async {
        repoStorage ??= await RepoStorage.getInstance();
        List<GitRepo> repoEntities = repoStorage!.getAllRepos();
        selectedRepo ??= repoEntities.first;
        currentDirectory = selectedRepo!.getDirectory();
        List<FileSystemEntity> directoryEntity =
            await currentDirectory!.list().toList();
        List<File> fileEntities = [];
        List<Directory> directoryEntities = [];
        for (FileSystemEntity element in directoryEntity) {
          if (element is File) {
            fileEntities.add(element);
          } else if (element is Directory) {
            directoryEntities.add(element);
          }
        }
        emit(
          HomeInitialState(
              repoEntities: repoEntities,
              directoryEntities: directoryEntities,
              fileEntities: fileEntities,
              initialRepo: selectedRepo!),
        );
      },
    );

    on<HomeBackPressEvent>(
      (event, emit) async {
        if (currentDirectory == null ||
            selectedRepo == null ||
            currentDirectory!.path == selectedRepo!.getDirectory().path) {
          emit(HomeBackCloseState());
        } else {
          currentDirectory = currentDirectory!.parent;
          List<FileSystemEntity> directoryEntity =
              await currentDirectory!.list().toList();
          List<File> fileEntities = [];
          List<Directory> directoryEntities = [];
          for (FileSystemEntity element in directoryEntity) {
            if (element is File) {
              fileEntities.add(element);
            } else if (element is Directory) {
              directoryEntities.add(element);
            }
          }
          emit(HomeTriggerAnimationState());
          await Future.delayed(Durations.medium1);
          emit(HomeUpdateDirectoryState(directoryEntities, fileEntities));
        }
      },
    );
  }
}
