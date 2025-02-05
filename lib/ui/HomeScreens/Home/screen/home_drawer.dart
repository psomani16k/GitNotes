import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:git_notes/helpers/git/git_repo.dart';

import 'package:git_notes/helpers/git/git_repo_manager.dart';
import 'package:git_notes/ui/GitCloneScreen/bloc/git_clone_bloc.dart';
import 'package:git_notes/ui/GitCloneScreen/screen/git_clone_screen.dart';
import 'package:git_notes/ui/GitPushPull/bloc/git_push_pull_bloc.dart';
import 'package:git_notes/ui/HomeScreens/HomeDirectory/bloc/home_directory_bloc.dart';
import 'package:git_notes/ui/HomeScreens/HomeGit/bloc/home_git_bloc.dart';
import 'package:git_notes/ui/SettingsScreen/Settings/settings.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  late double width;

  @override
  Widget build(BuildContext context) {
    // width = math.min(MediaQuery.sizeOf(context).width * 0.75, 250);
    return Drawer(
      // width: width,
      child: Container(
        // width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          top: true,
          bottom: true,
          left: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 0, 24),
                child: Text(
                  "GitNotes",
                  style: TextTheme.of(context).titleLarge,
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 12, 0, 12),
                child: Text(
                  "Repositories",
                  style: TextTheme.of(context).titleMedium,
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
              ),
              repositories(context),
              const Spacer(),
              const Divider(
                height: 1,
                thickness: 1,
              ),
              InkWell(
                onTap: () {
                  // close the drawer
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const GitCloneScreen(),
                    ),
                  );
                },
                child: SizedBox(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Icon(
                          MaterialIcons.add_circle_outline,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 24,
                        ),
                      ),
                      Text(
                        "New Repository",
                        style: TextTheme.of(context).titleMedium,
                      )
                    ],
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
              ),
              InkWell(
                onTap: () {
									GitCloneBloc cloneBloc = BlocProvider.of<GitCloneBloc>(context).add(GitCloneInitialEvent());
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                child: SizedBox(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Icon(
                          Icons.settings_outlined,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 24,
                        ),
                      ),
                      Text(
                        "Settings",
                        style: TextTheme.of(context).titleMedium,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget repositories(BuildContext context) {
    List<GitRepo> repos = GitRepoManager.getInstance().getAllRepos();

    return SingleChildScrollView(
      child: Column(
        children: repos.map((repo) {
          bool selected = GitRepoManager.getInstance().getRepo() == repo;
          return Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () {
                GitRepoManager.getInstance().setCurrentRepo(repo);
                BlocProvider.of<HomeDirectoryBloc>(context)
                    .add(HomeDirectoryRepoUpdateEvent());
                BlocProvider.of<HomeGitBloc>(context)
                    .add(HomeGitRepoUpdateEvent());
                BlocProvider.of<GitPushPullBloc>(context)
                    .add(GitPushPullUpdateEvent());
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: selected
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Colors.transparent,
                ),
                height: 48,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Icon(
                        selected
                            ? MaterialCommunityIcons.folder_multiple
                            : MaterialCommunityIcons.folder_multiple_outline,
                        color: selected
                            ? Theme.of(context).colorScheme.onSecondaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                        size: 22,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          repo.getRepoId().split("/").last,
                          style: TextTheme.of(context).titleMedium,
                        ),
                        Text(
                          repo.getRepoId(),
													overflow: TextOverflow.ellipsis,
                          style: TextTheme.of(context).labelSmall!.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer
                                    .withAlpha(120),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
