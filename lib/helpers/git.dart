import 'dart:async';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:git_notes/helpers/directory.dart';
import 'package:git_notes/messages/clone.pb.dart';
import 'package:rinf/rinf.dart';

class GitHelper {
  static GitHelper? _instance;

  DirectoryHelper _directoryHelper;
  String? _url;
  String? _userName;
  String? _password;

  GitHelper._(this._directoryHelper);

  void setUserName(String userName) {
    _userName = userName;
  }

  void setPassword(String password) {
    _password = password;
  }

  void setUrl(String url) {
    _url = url;
  }

  void saveToStorage() async {
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    await secureStorage.write(key: "_userName", value: _userName);
    await secureStorage.write(key: "_password", value: _password);
    await secureStorage.write(key: "_url", value: _url);
  }

  static Future<GitHelper> getInstance() async {
    if (_instance == null) {
      DirectoryHelper helper = await DirectoryHelper.getInstance();
      _instance = GitHelper._(helper);
    }
    return _instance!;
  }

  /// Returns the instance of [GitHelper] stored in secure storage.
  /// Returns null if no such data exists in secure storage
  static Future<GitHelper?> fromLocalStorage() async {
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    String? url = await secureStorage.read(key: "_url");
    if (url == null) {
      return null;
    }
    String? password = await secureStorage.read(key: "_password");
    String? userName = await secureStorage.read(key: "_userName");
    GitHelper gitHelper = await getInstance();
    gitHelper.setUrl(url);
    if (password != null) {
      gitHelper.setPassword(password);
    }
    if (userName != null) {
      gitHelper.setUserName(userName);
    }
    return gitHelper;
  }

  /// Performs a "git clone" with on the url using the provided username and password
  /// Returns [CloneCallback] with the status of the cloning process
  Future<CloneCallback> clone() async {
    Stream<RustSignal<CloneCallback>> rustStream =
        CloneCallback.rustSignalStream;

    CloneRepo(
      directoryPath: await _directoryHelper.prepareForClone(),
      repoUrl: _url,
      password: _password,
      user: _userName,
    ).sendSignalToRust();
    RustSignal<CloneCallback> callback = await rustStream.first;
    return callback.message;
  }

  /// Returns true if /GitNotes/.git folder exists and is not empty, false otherwise.
  Future<bool> checkRepoExists() async {
    try {
      Directory gitDir = _directoryHelper.getGitDirectory();
      Stream<FileSystemEntity> gitDirContents = gitDir.list();
      await gitDirContents.first;
    } catch (e) {
      return false;
    }
    return true;
  }

  /// Performs "git pull" on the repository.
  // Future<>
}
