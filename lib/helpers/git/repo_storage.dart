import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:git_notes/helpers/git/git_repo.dart';

class RepoStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static RepoStorage? _instance;
  final Map<String, GitRepo> _cache = {};

  RepoStorage._();

  void _cacheData() async {
    String repoString = await _storage.read(key: "repos") ?? "";
    var cache = jsonDecode(repoString) as Map<String, dynamic>;
    cache.forEach((repoId, repo) {
      _cache[repoId] = GitRepo.fromMap(repo);
    });
  }

  static RepoStorage getInstance() {
    _instance ??= RepoStorage._();
    _instance?._cacheData();
    return _instance!;
  }

  void storeRepo(GitRepo repo) async {
    _cache[repo.repoId!] = repo;
    String reposString = jsonEncode(_cache);
    await _storage.write(key: "repos", value: reposString);
  }

  GitRepo? getRepo(String id) {
    return _cache[id];
  }

  List<GitRepo> getAllRepos() {
    return _cache.values.toList();
  }
}