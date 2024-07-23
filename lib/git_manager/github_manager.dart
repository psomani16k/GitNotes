import 'package:github/github.dart';

class GithubManager {
  GitHub _githubClient = GitHub();

  Future<void> setCredentials(String user, String password) async {
    Authentication auth = Authentication.basic(user, password);
    _githubClient.auth = auth;
    final repos = _githubClient.repositories.listRepositories();
    await repos.forEach((repo) {
      print(repo.cloneUrl);
    });
  }

  // List<String> getListOfRepos(){

  // }
}
