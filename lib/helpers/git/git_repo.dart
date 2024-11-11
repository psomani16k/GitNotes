import 'dart:async';
import 'dart:io';
import 'package:git_notes/helpers/directory.dart';
import 'package:git_notes/helpers/git/repo_storage.dart';
import 'package:git_notes/messages/clone.pb.dart';
import 'package:git_notes/messages/pull.pbserver.dart';
import 'package:rinf/rinf.dart';

class GitRepo {
  // TODO: add a way to manage the branch of the repository
  static DirectoryHelper? _directoryHelper;
  String _url;
  String _userName;
  String? _password;
  late String _directory;
  String? repoId;
  late String _branch;

// initiation
  static Future<void> init() async {
    _directoryHelper = await DirectoryHelper.getInstance();
  }

// construction
  GitRepo(this._url, this._userName);

  static GitRepo fromJson(Map<String, dynamic> map) {
    GitRepo repo = GitRepo(map["url"]!, map["username"]!.toString());
    repo._password = map["password"].toString();
    repo._directory = map["directory"].toString();
    repo.repoId = map["repoId"].toString();
    repo._branch = map["branch"].toString();
    return repo;
  }

// setters
  void setUserName(String userName) {
    _userName = userName;
  }

  void setPassword(String? password) {
    _password = password;
  }

  void setUrl(String url) {
    _url = url;
  }

// getters
  /// Returns a [Map] with all the date of the repo
  /// Keys: url, username, directory, password
  Map toJson() {
    return {
      "url": _url,
      "username": _userName,
      "directory": _directory,
      "password": _password,
      "repoId": repoId,
      "branch": _branch
    };
  }

  /// Returns the directory of the repository
  Directory getDirectory() {
    return Directory(_directory);
  }

  String getRepoId() {
    return repoId!;
  }

  Future<void> _saveToStorage() async {
    await (RepoStorage.getInstance()).storeRepo(this);
  }

// utility functions
  /// Performs a "git clone" with on the url using the provided username and password
  /// Returns [CloneCallback] with the status of the cloning process
  Future<CloneCallback> cloneAndSaveRepo() async {
    Stream<RustSignal<CloneCallback>> rustStream =
        CloneCallback.rustSignalStream;
    CloneRepo(
      directoryPath: _directoryHelper!.getHomeDirectory().path,
      repoUrl: _url,
      password: _password,
      user: _userName,
    ).sendSignalToRust();
    RustSignal<CloneCallback> callback = await rustStream.first;
    if (callback.message.status == CloneResult.Success) {
      repoId = callback.message.data;
      _branch = callback.message.branch;
      _directory = "${_directoryHelper!.getHomeDirectory().path}/$repoId";
      _saveToStorage();
    }
    return callback.message;
  }

  /// Aims to perform a "git pull" on the repository associated with the object
  /// Returns [PullSingleCallback] on completion with the result of the operation.
  Future<PullSingleCallback> pull() async {
    Stream<RustSignal<PullSingleCallback>> rustStream =
        PullSingleCallback.rustSignalStream;

    PullSingleRepo(
      directoryPath: _directory,
      password: _password,
      user: _userName,
    ).sendSignalToRust();

    RustSignal<PullSingleCallback> callback = await rustStream.first;
    return callback.message;
  }
}
