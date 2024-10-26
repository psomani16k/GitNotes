import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:git_notes/helpers/git/git_repo.dart';

class RepoStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static RepoStorage? _instance;
  final Map<String, GitRepo> _cache = {};

  RepoStorage._();

  Future<void> _cacheData() async {
    String repoString = await _storage.read(key: "repos") ?? "{}";
    var cache = jsonDecode(repoString);
    cache.forEach((repoId, repo) {
      _cache[repoId] = GitRepo.fromJson(repo);
    });
  }

  static Future<RepoStorage> getInstance() async {
    _instance ??= RepoStorage._();
    await _instance?._cacheData();
    return _instance!;
  }

  Future<void> storeRepo(GitRepo repo) async {
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
