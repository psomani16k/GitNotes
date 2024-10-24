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

  static Future<bool> init() async {
    _directoryHelper = await DirectoryHelper.getInstance();
    return true;
  }

  GitRepo(this._url, this._userName);

  static GitRepo fromJson(Map<String, String> map) {
    GitRepo repo = GitRepo(map["url"]!, map["username"]!);
    repo._password = map["password"];
    repo._directory = map["directory"];
    repo.repoId = map["repoId"];
    return repo;
  }

  void setUserName(String userName) {
    _userName = userName;
  }

  void setPassword(String? password) {
    _password = password;
  }

  void setUrl(String url) {
    _url = url;
  }

  Future<void> _saveToStorage() async {
    await RepoStorage.getInstance().storeRepo(this);
  }

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
          "${_directoryHelper!.getHomeDirectory()}/${callback.message.data}";
      repoId = callback.message.data;
      _saveToStorage();
    }
    return callback.message;
  }

  /// Returns the directory of the repository
  Directory? getDirectory() {
    return _directory == null ? null : Directory(_directory!);
  }

  String getRepoId() {
    return repoId!;
  }
}
