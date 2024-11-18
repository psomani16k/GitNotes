import 'dart:io';

import 'package:git_notes/helpers/git/directory.dart';
import 'package:git_notes/helpers/git/git_repo.dart';
import 'package:git_notes/helpers/git/repo_storage.dart';
import 'package:git_notes/messages/commit_push_check.pb.dart';
import 'package:git_notes/messages/git_add.pb.dart';
import 'package:git_notes/messages/git_clone.pb.dart';
import 'package:git_notes/messages/git_commit.pb.dart';
import 'package:git_notes/messages/git_pull.pb.dart';
import 'package:git_notes/messages/git_push.pb.dart';
import 'package:git_notes/messages/git_restore.pb.dart';
import 'package:git_notes/messages/git_status.pb.dart';

class GitRepoManager {
  GitRepo? _currentRepo;
  List<GitRepo> _repos;

  static GitRepoManager? _instance;

  GitRepoManager._(this._repos);

  static Future<void> init() async {
    await RepoStorage.init();
    await DirectoryHelper.init();
    await GitRepo.init();
    List<GitRepo> repos = RepoStorage.getInstance().getAllRepos();
    _instance = GitRepoManager._(repos);
    if (_instance!._repos.isNotEmpty) {
      _instance!._currentRepo = _instance!._repos.first;
    }
  }

  static GitRepoManager getInstance() {
    // assuming init() is called already, then _instance is not going to be null
    return _instance!;
  }

  GitRepo? getRepo() {
    return _currentRepo;
  }

  List<GitRepo> getAllRepos() {
    return _repos;
  }

  void setCurrentRepo(GitRepo repo) {
    _currentRepo = repo;
  }

  /// returns true if atlease one repo exists
  bool repoExists() {
    return _currentRepo != null && _repos.isNotEmpty;
  }

  /// returns the name of the current repo if it exists, null otherwise
  String? repoName() {
    if (_currentRepo == null) {
      return null;
    }
    return _currentRepo!.repoId?.split("/").last;
  }

  /// returns the base directory of the current repo
  Directory? repoDirectory() {
    if (_currentRepo == null) {
      return null;
    }
    return _currentRepo!.getDirectory();
  }

  /// Performs a clone on a new repo with the details provided.
  /// If successful stores the repository
  /// in [RepoStorage] and updates the [_repos]
  /// and [_currentRepo] field if it is null.
  Future<GitCloneCallback> clone(
      String userName, String userEmail, String url, String? password) async {
    GitRepo repo = GitRepo(url, userEmail, userName);
    if (password != null) {
      repo.setPassword(password);
    }
    GitCloneCallback callback = await repo.gitClone();
    if (callback.status == GitCloneResult.Success) {
      await RepoStorage.getInstance().addRepo(repo);
      _repos = RepoStorage.getInstance().getAllRepos();
      _currentRepo ??= repo;
    }
    return callback;
  }

  /// Performs a pull on the current repository if it exists.
  Future<GitPullSingleCallback?> pull() async {
    if (_currentRepo == null) {
      return null;
    }
    return _currentRepo!.gitPull();
  }

  Future<GitStatusCallback?> status() async {
    if (_currentRepo == null) {
      return null;
    }
    return _currentRepo!.gitStatus();
  }

  Future<GitAddCallback?> stage(String relativeFilePath) async {
    if (_currentRepo == null) {
      return null;
    }
    return _currentRepo!.gitAdd(relativeFilePath);
  }

  Future<GitRemoveCallback?> unstage(String relativeFilePath) async {
    if (_currentRepo == null) {
      return null;
    }
    return _currentRepo!.gitRemove(relativeFilePath);
  }

  Future<GitRestoreCallback?> restore(String relativeFilePath) async {
    if (_currentRepo == null) {
      return null;
    }
    return _currentRepo!.gitRestore(relativeFilePath);
  }

  Future<GitCommitCallback?> commit(String message) async {
    if (_currentRepo == null) {
      return null;
    }
    return _currentRepo!.gitCommit(message);
  }

  Future<GitPushCallback?> push() async {
    if (_currentRepo == null) {
      return null;
    }
    return _currentRepo!.gitPush();
  }

  Future<CommitAndPushCheckCallback?> checkCommitAndPush() async {
    if (_currentRepo == null) {
      return null;
    }
    return _currentRepo!.checkCommitAndPush();
  }
}
