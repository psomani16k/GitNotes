import 'dart:async';
import 'dart:io';
import 'package:git_notes/helpers/git/directory.dart';
import 'package:git_notes/messages/commit_push_check.pb.dart';
import 'package:git_notes/messages/git_add.pb.dart';
import 'package:git_notes/messages/git_clone.pb.dart';
import 'package:git_notes/messages/git_commit.pb.dart';
import 'package:git_notes/messages/git_pull.pb.dart';
import 'package:git_notes/messages/git_push.pb.dart';
import 'package:git_notes/messages/git_restore.pb.dart';
import 'package:git_notes/messages/git_status.pb.dart';
import 'package:rinf/rinf.dart';

class GitRepo {
  static DirectoryHelper? _directoryHelper;
  final String _url;
  final String _name;
  final String _email;
  String? _password;
  late String _directory;
  String? repoId;
  late String _branch;

// initiation
  static Future<void> init() async {
    _directoryHelper = DirectoryHelper.getInstance();
  }

// construction
  GitRepo(this._url, this._email, this._name);

  static GitRepo fromJson(Map<String, dynamic> map) {
    GitRepo repo = GitRepo(map["url"]!, map["email"], map["name"]);
    repo._password = map["password"].toString();
    repo._directory = map["directory"].toString();
    repo.repoId = map["repoId"].toString();
    repo._branch = map["branch"].toString();
    return repo;
  }

// setters

  void setPassword(String? password) {
    _password = password;
  }

// getters
  /// Returns a [Map] with all the date of the repo
  /// Keys: url, username, directory, password
  Map toJson() {
    return {
      "name": _name,
      "url": _url,
      "email": _email,
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

// -------------utility functions-----------------

  /// Performs a "git clone" with on the url using the provided username and password
  /// Returns [GitCloneCallback] with the status of the cloning process
  Future<GitCloneCallback> gitClone() async {
    Stream<RustSignal<GitCloneCallback>> rustStream =
        GitCloneCallback.rustSignalStream;
    GitCloneRequest(
      directoryPath: _directoryHelper!.getHomeDirectory().path,
      repoUrl: _url,
      password: _password ?? "",
      user: _email,
    ).sendSignalToRust();
    RustSignal<GitCloneCallback> callback = await rustStream.first;
    if (callback.message.status == GitCloneResult.Success) {
      repoId = callback.message.data;
      _branch = callback.message.branch;
      _directory = "${_directoryHelper!.getHomeDirectory().path}/$repoId";
    }
    return callback.message;
  }

  /// Aims to perform a "git pull" on the repository associated with the object
  /// Returns [GitPullSingleCallback] on completion with the result of the operation.
  Future<GitPullSingleCallback> gitPull() async {
    Stream<RustSignal<GitPullSingleCallback>> rustStream =
        GitPullSingleCallback.rustSignalStream;
    GitPullSingle(
      directoryPath: _directory,
      password: _password,
      user: _email,
			name: _name
    ).sendSignalToRust();

    RustSignal<GitPullSingleCallback> callback = await rustStream.first;
    return callback.message;
  }

  /// Performs a "git status" on the repository and returns the data
  /// (custom) encoded in a string. NOTE the data will not be the same as
  /// a normal git status
  Future<GitStatusCallback> gitStatus() async {
    Stream<RustSignal<GitStatusCallback>> rustStream =
        GitStatusCallback.rustSignalStream;
    GitStatus(repoDirectory: _directory).sendSignalToRust();
    RustSignal<GitStatusCallback> callback = await rustStream.first;
    return callback.message;
  }

  /// Performs a "git add" on the file mentioned
  Future<GitAddCallback> gitAdd(String relativeFilePath) async {
    Stream<RustSignal<GitAddCallback>> rustStream =
        GitAddCallback.rustSignalStream;
    GitAdd(
            repoDir: _directory,
            absoluteFilePath: "$_directory/$relativeFilePath")
        .sendSignalToRust();
    RustSignal<GitAddCallback> callback = await rustStream.first;
    return callback.message;
  }

  /// Performs a "git add" on the file mentioned
  Future<GitRemoveCallback> gitRemove(String relativeFilePath) async {
    Stream<RustSignal<GitRemoveCallback>> rustStream =
        GitRemoveCallback.rustSignalStream;
    GitRemove(
            repoDir: _directory,
            absoluteFilePath: "$_directory/$relativeFilePath")
        .sendSignalToRust();
    RustSignal<GitRemoveCallback> callback = await rustStream.first;
    return callback.message;
  }

  /// Performs a "git restore" on the file mentioned
  Future<GitRestoreCallback> gitRestore(String relativeFilePath) async {
    Stream<RustSignal<GitRestoreCallback>> rustStream =
        GitRestoreCallback.rustSignalStream;
    GitRestore(
            repoDir: _directory,
            absoluteFilePath: "$_directory/$relativeFilePath")
        .sendSignalToRust();
    RustSignal<GitRestoreCallback> callback = await rustStream.first;
    return callback.message;
  }

  /// Performs a "git commit" on the staged files
  Future<GitCommitCallback> gitCommit(String message) async {
    Stream<RustSignal<GitCommitCallback>> rustStream =
        GitCommitCallback.rustSignalStream;
    GitCommitRequest(
            repoDir: _directory, email: _email, name: _name, message: message)
        .sendSignalToRust();
    RustSignal<GitCommitCallback> callback = await rustStream.first;
    return callback.message;
  }

  /// Performs a "git push"
  Future<GitPushCallback> gitPush() async {
    Stream<RustSignal<GitPushCallback>> rustStream =
        GitPushCallback.rustSignalStream;
    GitPushRequest(
            email: _email, password: _password ?? "", repoDir: _directory)
        .sendSignalToRust();
    RustSignal<GitPushCallback> callback = await rustStream.first;
    return callback.message;
  }

  /// Performs a "git push"
  Future<CommitAndPushCheckCallback> checkCommitAndPush() async {
    Stream<RustSignal<CommitAndPushCheckCallback>> rustStream =
        CommitAndPushCheckCallback.rustSignalStream;
    CommitAndPushCheck(repoDir: _directory).sendSignalToRust();
    RustSignal<CommitAndPushCheckCallback> callback = await rustStream.first;
    print("2");
    return callback.message;
  }
}
