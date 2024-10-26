import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:git_notes/helpers/git/git_repo.dart';
import 'package:git_notes/helpers/git/repo_storage.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  late RepoStorage repoStorage;
  late GitRepo selectedRepo;

  HomeBloc() : super(HomeInitial()) {
    on<HomeInitialEvent>(
      (event, emit) async {
        repoStorage = await RepoStorage.getInstance();
        List<GitRepo> repoEntities = repoStorage.getAllRepos();
        if (repoEntities.isEmpty) {
          emit(HomeNoRepoState());
        } else {
          selectedRepo = repoEntities.first;

          // this directory will exist if the repos exists...
          Directory repoDirectory = selectedRepo.getDirectory()!;
          List<FileSystemEntity> directoryEntity =
              await repoDirectory.list().toList();
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
                initialRepo: selectedRepo),
          );
        }
      },
    );

    on<HomeChooseRepoEvent>(
      (event, emit) async {
        selectedRepo = event.choosenRepo;
        Directory repoDirectory = selectedRepo.getDirectory()!;
        List<FileSystemEntity> directoryEntity =
            await repoDirectory.list().toList();
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
            directoryEntities, fileEntities, selectedRepo));
      },
    );

    on<HomeChooseDirectoryEvent>(
      (event, emit) async {
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
        emit(HomeUpdateDirectoryState(directoryEntities, fileEntities));
      },
    );
  }
}
