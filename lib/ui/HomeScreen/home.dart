import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:git_notes/helpers/git/git_repo_manager.dart';
import 'package:git_notes/helpers/git/git_repo.dart';
import 'package:git_notes/ui/GitCloneScreen.dart/git_clone_screen.dart';
import 'package:git_notes/ui/HomeScreen/sub_screens/home_directory.dart';
import 'package:git_notes/ui/HomeScreen/sub_screens/home_status.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void handleFloatingActionButton() {}

  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      drawer: homeDrawer(350),
      appBar: homeAppBar(context),
      floatingActionButton: homeFloatingActionButton(),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(MaterialCommunityIcons.folder),
            label: "Directory",
          ),
          NavigationDestination(
            icon: Icon(MaterialCommunityIcons.git),
            label: "Git",
          )
        ],
        selectedIndex: pageIndex,
        onDestinationSelected: (value) {
          setState(() {
            pageIndex = value;
          });
        },
      ),
      body: [
        HomeDirectory(
          repoDir: GitRepoManager.getInstance().repoDirectory(),
        ),
        HomeStatus(
          repo: GitRepoManager.getInstance().getRepo(),
        )
      ][pageIndex],
    );
  }

  Widget homeFloatingActionButton() {
    return Builder(builder: (context) {
      return FloatingActionButton(
        onPressed: () async {
          if (pageIndex == 0) {
            await showModalBottomSheet(
              context: context,
              showDragHandle: true,
              enableDrag: true,
              elevation: 10,
              isDismissible: true,
              builder: (context) {
                return FutureBuilder(
                  future: GitRepoManager.getInstance().pull(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(snapshot.data!.data),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox(
                      height: 150,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                );
              },
            );
            setState(() {});
          } else if (pageIndex == 1) {}
        },
        child: Icon(
          (pageIndex == 0) ? Icons.download : Icons.upload,
        ),
      );
    });
  }

  AppBar homeAppBar(BuildContext context) {
    return AppBar(
      title: Text(GitRepoManager.getInstance().repoName() ?? "GitNotes"),
    );
  }

  Drawer homeDrawer(double drawerWidth) {
    return Drawer(
      width: drawerWidth,
      child: SafeArea(
        top: true,
        child: Builder(builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: drawerWidth * 0.1, vertical: 16),
                child: Text(
                  "GitNotes",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const Divider(
                height: 2,
                thickness: 2,
              ),
              const SizedBox(height: 4),
              // List of repos,
              Expanded(
                child: ListView.builder(
                  itemCount: GitRepoManager.getInstance().getAllRepos().length,
                  itemBuilder: (context, index) {
                    GitRepo repo =
                        GitRepoManager.getInstance().getAllRepos()[index];
                    return InkWell(
                      onTap: () {
                        Scaffold.of(context).closeDrawer();
                        setState(() {
                          GitRepoManager.getInstance().setCurrentRepo(repo);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 42,
                          top: 16,
                          bottom: 16,
                        ),
                        child: Text(repo.repoId!),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              InkWell(
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const GitCloneScreen(),
                  ));
                  setState(() {});
                },
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      child: Icon(Icons.add),
                    ),
                    Text("New repository")
                  ],
                ),
              ),
              const Divider(),
              // settings button
              InkWell(
                onTap: () {
                  // TODO: route to settings page
                },
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                      child: Icon(
                        Icons.settings_outlined,
                      ),
                    ),
                    Text("Settings")
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
