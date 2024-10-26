import 'dart:async';
import 'dart:io';
import 'package:git_notes/helpers/directory.dart';
import 'package:git_notes/helpers/git/repo_storage.dart';
import 'package:git_notes/messages/clone.pb.dart';
import 'package:rinf/rinf.dart';

class GitRepo {
  static DirectoryHelper? _directoryHelper;
  String _url;
  String _userName;
  String? _password;
  String? _directory;
  String? repoId;

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
    };
  }

  /// Returns the directory of the repository
  Directory? getDirectory() {
    return _directory == null ? null : Directory(_directory!);
  }

  String getRepoId() {
    return repoId!;
  }

  Future<void> _saveToStorage() async {
    await (await RepoStorage.getInstance()).storeRepo(this);
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
      _directory =
          "${_directoryHelper!.getHomeDirectory().path}/${callback.message.data}";
      repoId = callback.message.data;
      _saveToStorage();
    }
    return callback.message;
  }
}
