import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:git_notes/ui/GitPushPull/screen/git_push_pull.dart';
import 'package:git_notes/ui/HomeScreens/Home/screen/home_drawer.dart';
import 'package:git_notes/ui/HomeScreens/HomeDirectory/screen/home_directory.dart';
import 'package:git_notes/ui/HomeScreens/HomeGit/screen/home_git.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeDirectory _homeDirectory = const HomeDirectory();

  final HomeGit _homeGit = const HomeGit();

  final GitPushPull _gitPushPull = const GitPushPull();

  // State variables
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.swap_vert),
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => _gitPushPull,
            ),
          );
        },
      ),
      appBar: AppBar(
        title: Text(
          "GitNotes",
          style: TextTheme.of(context).headlineMedium,
        ),
      ),
      drawer: const HomeDrawer(),
      body: [_homeDirectory, _homeGit][pageIndex],
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
          // no need to use bloc here...
          setState(() {
            pageIndex = value;
          });
        },
      ),
    );
  }
}
