import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:git_notes/helpers/directory.dart';
import 'package:git_notes/helpers/git.dart';
import 'package:git_notes/messages/clone.pb.dart';
import 'package:git_notes/ui/HomeScreen/model/directory_model.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeDirectoryModel? _dirModel;
  GitHelper? _gitHelper;

  HomeBloc() : super(HomeInitial()) {
    // 1. Initialize the _dirModel, _gitHelper, etc.
    // 2. if git credentials exists but repo uncloned, clone the repo,
    //    else if git credentials exists, and repo cloned, perform a "git pull"
    //    else emit(HomeConfigureGitState)
    on<HomeInitialEvent>((event, emit) async {
      // setting up HomeDirectoryModel
      DirectoryHelper helper = await DirectoryHelper.getInstance();
      _dirModel = HomeDirectoryModel(helper);

      // setting up GitHelper
      _gitHelper = await GitHelper.fromLocalStorage();

      if (_gitHelper == null) {
        // if there is no git userdata then _gitHelper will be null
        // in this case we need to request the user for git data and save it
        emit(HomeConfigureGitState());
      } else if (await _gitHelper!.checkRepoExists()) {
        // if the repo does not exists,
        emit(HomeSetLoadingState("Cloning"));
        CloneCallback cloneResult = await _gitHelper!.clone();
        if (cloneResult.status == CloneResult.Fail) {
          // TODO: Handle error case
        }
      } else {
        // await _gitHelper.pull();
      }
    });
  }
}
