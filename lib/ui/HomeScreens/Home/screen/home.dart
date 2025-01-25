import 'dart:math' as math;
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:git_notes/helpers/git/git_repo.dart';
import 'package:git_notes/helpers/git/git_repo_manager.dart';
import 'package:git_notes/messages/git_add.pb.dart';
import 'package:git_notes/messages/git_restore.pb.dart';
import 'package:git_notes/messages/git_status.pb.dart';
import 'package:git_notes/ui/GitCloneScreen/bloc/git_clone_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:git_notes/ui/GitCloneScreen/screen/git_clone_screen.dart';
import 'package:git_notes/ui/HomeScreens/Home/bloc/home_bloc.dart';
import 'package:git_notes/ui/MarkdownRendering/screen/markdown_rendering_screen.dart';
import 'package:git_notes/ui/SettingsScreen/Settings/settings.dart';
import 'package:open_file_plus/open_file_plus.dart';

import 'package:page_transition/page_transition.dart';
import 'package:text_scroll/text_scroll.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GitRepo? _currentRepo;

  final HomeDirectory _homeDirectory = HomeDirectory(
    repoDir: GitRepoManager.getInstance().repoDirectory(),
  );

  final HomeGit _homeGit = HomeGit(
    repo: GitRepoManager.getInstance().getRepo(),
  );

  // State variables
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    HomeBloc bloc = BlocProvider.of<HomeBloc>(context);
    return BlocConsumer<HomeBloc, HomeState>(
      bloc: bloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is HomeSetRepositoryState) {
          _currentRepo = state.repo;
        }
        return Scaffold(
          drawerEnableOpenDragGesture: false,
          drawer: homeDrawer(
              math.min(MediaQuery.sizeOf(context).width * 0.75, 300)),
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
              // no need to use bloc here...
              setState(() {
                pageIndex = value;
              });
            },
          ),
          body: [
            _homeDirectory,
            _homeGit,
          ][pageIndex],
        );
      },
    );
  }

  Widget homeFloatingActionButton() {
    return Builder(builder: (context) {
      return FloatingActionButton(
        onPressed: () async {
          if (pageIndex == 0) {
            await showModalBottomSheet(
              useSafeArea: true,
              context: context,
              showDragHandle: true,
              enableDrag: true,
              elevation: 10,
              isDismissible: true,
              builder: (context) {
                if (!GitRepoManager.getInstance().repoExists()) {
                  return SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: 300,
                    child: const Center(
                      child: Text("No repository to pull from."),
                    ),
                  );
                }
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
          } else if (pageIndex == 1) {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true, // Allows resizing to avoid the keyboard
              useSafeArea: true,
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context)
                        .viewInsets
                        .bottom, // Adjust for keyboard height
                    left: 20,
                    right: 20,
                  ),
                  child: const SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 20),
                        _PushAndCommitBottomSheet(),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          setState(() {});
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
                  await Navigator.of(context).push(
                    PageTransition(
                      child: const GitCloneScreen(),
                      type: PageTransitionType.rightToLeftWithFade,
                      curve: Easing.emphasizedAccelerate,
                      reverseDuration: Durations.medium2,
                      duration: Durations.long1,
                    ),
                  );
                  GitCloneBloc gitCloneBloc =
                      BlocProvider.of<GitCloneBloc>(context);
                  gitCloneBloc.add(GitCloneInitialEvent());
                  // TODO: replace this with something that sets current repo to the new
                  // repo if it was previously empty also maybe use bloc here
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
                onTap: () async {
                  await Navigator.of(context).push(
                    PageTransition(
                      child: const SettingsScreen(),
                      type: PageTransitionType.rightToLeftWithFade,
                      curve: Easing.emphasizedAccelerate,
                      reverseDuration: Durations.medium2,
                      duration: Durations.long1,
                    ),
                  );
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

// Directory comes here

class HomeDirectory extends StatefulWidget {
  const HomeDirectory({super.key, required this.repoDir});
  final Directory? repoDir;

  @override
  State<HomeDirectory> createState() => _HomeDirectoryState();
}

class _HomeDirectoryState extends State<HomeDirectory> {
// Page data
  final Map<String, IconData> fileIcons = {
    "gitignore": MaterialCommunityIcons.git,
    "md": MaterialCommunityIcons.language_markdown,
    "pdf": MaterialCommunityIcons.file_pdf_box,
    "xlss": MaterialCommunityIcons.microsoft_excel,
    "ppt": MaterialCommunityIcons.microsoft_powerpoint,
    "pptx": MaterialCommunityIcons.microsoft_powerpoint,
    "jpg": MaterialCommunityIcons.file_jpg_box,
    "png": MaterialCommunityIcons.file_png_box,
    "rs": MaterialCommunityIcons.language_rust,
    "js": MaterialCommunityIcons.language_javascript,
    "ts": MaterialCommunityIcons.language_typescript,
    "html": MaterialCommunityIcons.language_html5,
    "lua": MaterialCommunityIcons.language_lua,
    "go": MaterialCommunityIcons.language_go,
    "c": MaterialCommunityIcons.language_c,
    "cpp": MaterialCommunityIcons.language_cpp,
    "java": MaterialCommunityIcons.language_java,
    "py": MaterialCommunityIcons.language_python,
  };

  @override
  void didUpdateWidget(covariant HomeDirectory oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentDirectory = widget.repoDir;
    populateData();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentDirectory = widget.repoDir;
  }

  void populateData() async {
    if (currentDirectory == null) {
      return;
    }
    currentDirectory ??= widget.repoDir;
    if (!currentDirectory!.path.startsWith(widget.repoDir!.path)) {
      currentDirectory = widget.repoDir;
    }
    List<FileSystemEntity> fileSystemEntities =
        await currentDirectory!.list().toList();
    fileEntities = [];
    directoryEntities = [];
    for (FileSystemEntity entity in fileSystemEntities) {
      if (entity is File) {
        fileEntities.add(entity);
      } else if (entity is Directory) {
        directoryEntities.add(entity);
      }
    }
    setState(() {});
  }

  List<File> fileEntities = [];
  List<Directory> directoryEntities = [];
  bool updated = false;
  bool shouldPop = false;
  Directory? currentDirectory;
  bool reverseAnimation = false;

  @override
  Widget build(BuildContext context) {
    if (widget.repoDir == null) {
      return const Center(
        child: Text("Please clone a repository to continue."),
      );
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (widget.repoDir!.path == currentDirectory!.path && !shouldPop) {
          shouldPop = true;
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Press again to exit.")));
          return;
        }
        if (widget.repoDir!.path == currentDirectory!.path && shouldPop) {
          SystemNavigator.pop();
          return;
        }
        if (currentDirectory != null) {
          currentDirectory = currentDirectory!.parent;
          reverseAnimation = true;
          populateData();
          return;
        }
      },
      child: VisibilityDetector(
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.1 && !updated) {
            populateData();
            updated = true;
          } else {
            updated = false;
          }
        },
        key: const Key("home-directory"),
        child: PageTransitionSwitcher(
          reverse: reverseAnimation,
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
            return SharedAxisTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
          duration: Durations.medium2,
          child: KeyedSubtree(
              key: ValueKey(currentDirectory), child: homeDirectoryDirectory()),
        ),
      ),
    );
  }

  ListView homeDirectoryDirectory() {
    return ListView.builder(
      itemCount: fileEntities.length + directoryEntities.length + 1,
      itemBuilder: (context, index) {
        if (index < directoryEntities.length) {
          return directoryBox(directoryEntities[index]);
        }
        index = index - directoryEntities.length;
        if (index < fileEntities.length) {
          return fileBox(fileEntities[index]);
        }
        return const SizedBox(height: 90);
      },
    );
  }

  Widget directoryBox(Directory dir) {
    String name = dir.path.split("/").last;
    return InkWell(
      onTap: () {
        currentDirectory = dir;
        reverseAnimation = false;
        populateData();
      },
      child: SizedBox(
        height: 70,
        child: Column(
          children: [
            const Spacer(),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Icon(MaterialCommunityIcons.folder_outline),
                ),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - 150,
                  child: TextScroll(
                    name,
                    pauseBetween: const Duration(milliseconds: 1200),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Divider(
              thickness: 1,
              height: 1,
              indent: 70,
              endIndent: 15,
            )
          ],
        ),
      ),
    );
  }

  Widget fileBox(File file) {
    String name = file.path.split("/").last;
    String extension = name.split(".").last;
    return InkWell(
      onTap: () async {
        if (extension == "md") {
          Navigator.of(context).push(
            PageTransition(
              child: MarkdownRenderingScreen(file: file),
              childCurrent: widget,
              type: PageTransitionType.rightToLeftWithFade,
              curve: Curves.easeInOut,
              reverseDuration: Durations.long1,
              duration: Durations.long1,
            ),
          );
        } else {
          await OpenFile.open(file.path);
        }
      },
      child: SizedBox(
        height: 70,
        child: Column(
          children: [
            const Spacer(),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Icon(fileIcons[extension] ??
                      MaterialCommunityIcons.file_outline),
                ),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - 120,
                  child: TextScroll(
                    mode: TextScrollMode.endless,
                    "$name             ",
                    pauseBetween: const Duration(seconds: 2),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Divider(
              thickness: 1,
              height: 1,
              indent: 70,
              endIndent: 15,
            )
          ],
        ),
      ),
    );
  }
}

class HomeGit extends StatefulWidget {
  const HomeGit({super.key, required this.repo});
  final GitRepo? repo;
  @override
  State<HomeGit> createState() => _HomeGitState();
}

class _HomeGitState extends State<HomeGit> {
  @override
  void didUpdateWidget(covariant HomeGit oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateStatus();
  }

  void updateStatus() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    if (widget.repo == null) {
      return;
    }
    GitStatusCallback callback = await widget.repo!.gitStatus();
    staged = [];
    changed = [];
    for (String status in callback.status) {
      FileStatusData data = FileStatusData(status);
      if (data.isStaged()) {
        staged.add(data);
      } else {
        changed.add(data);
      }
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  List<FileStatusData> staged = [];
  List<FileStatusData> changed = [];
  bool updated = false;
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    if (widget.repo == null) {
      return const Center(
        child: Text("Please clone a repository to continue."),
      );
    }
    return VisibilityDetector(
      key: const Key("home-status"),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !updated) {
          updateStatus();
          updated = true;
        } else {
          updated = false;
        }
      },
      child: loading ? const LinearProgressIndicator() : homeStatusStatus(),
    );
  }

  Widget homeStatusStatus() {
    if (changed.length + staged.length == 0) {
      return const Center(
        child: Text("Nothing to see here!"),
      );
    }
    return ListView.builder(
      itemCount: changed.length + staged.length + 3,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer),
            height: 30,
            child: Center(
              child: Text(
                "Staged",
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
            ),
          );
        }
        index -= 1;
        if (index < staged.length) {
          return stagedBox(staged[index]);
        }
        index -= staged.length;
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer),
              height: 30,
              child: Center(
                child: Text(
                  "Changed",
                  style: TextStyle(
                      fontSize: 16,
                      color:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                ),
              ),
            ),
          );
        }
        index -= 1;
        if (index < changed.length) {
          return changedBox(changed[index]);
        }
        return const SizedBox(height: 90);
      },
    );
  }

  Widget stagedBox(FileStatusData statusData) {
    return SizedBox(
      height: 70,
      child: Column(
        children: [
          const Spacer(),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Center(
                  child: Text(
                    statusData._changeChar,
                    style: TextStyle(
                      color: statusData.getChangedCharColor(),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(statusData.getFileName()),
                  Text(
                    statusData.getFilePath(),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  )
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  await statusData.unstage();
                  updateStatus();
                },
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.primaryContainer),
                  child: Icon(
                    Icons.remove,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 20)
            ],
          ),
          const Spacer(),
          const Divider(
            thickness: 1,
            height: 1,
            indent: 60,
            endIndent: 10,
          )
        ],
      ),
    );
  }

  Widget changedBox(FileStatusData statusData) {
    return SizedBox(
      height: 70,
      child: Column(
        children: [
          const Spacer(),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Center(
                  child: Text(
                    statusData._changeChar,
                    style: TextStyle(
                      color: statusData.getChangedCharColor(),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(statusData.getFileName()),
                  Text(
                    statusData.getFilePath(),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  )
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  await statusData.restore();
                  updateStatus();
                },
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.tertiaryContainer),
                  child: Icon(
                    Icons.undo,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              GestureDetector(
                onTap: () async {
                  await statusData.stage();
                  updateStatus();
                },
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.primaryContainer),
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          const Spacer(),
          const Divider(
            thickness: 1,
            height: 1,
            indent: 60,
            endIndent: 10,
          )
        ],
      ),
    );
  }
}

class FileStatusData {
  File _file;
  bool _staged;
  String _changeChar;

  FileStatusData._(this._file, this._changeChar, this._staged);

  factory FileStatusData(String statusString) {
    bool staged = statusString.substring(0, 1) == "I";
    String changeChar = statusString.substring(1, 2);
    File file = File(statusString.substring(3));
    return FileStatusData._(file, changeChar, staged);
  }

  String getFileName() {
    return _file.path.split("/").last;
  }

  String getFilePath() {
    return _file.path;
  }

  String getChangeChar() {
    return _changeChar;
  }

  Color? getChangedCharColor() {
    switch (_changeChar) {
      case "N":
        return Colors.green;
      case "D":
        return Colors.red;
      case "M":
        return Colors.yellow;
      case "R":
        return Colors.lightGreen;
    }
    return null;
  }

  bool isStaged() {
    return _staged;
  }

  Future<bool?> stage() async {
    if (_staged) {
      return null;
    }
    GitAddCallback? result =
        await GitRepoManager.getInstance().stage(_file.path);
    if (result == null || result.result == GitAddResult.Fail) {
      return false;
    }
    return true;
  }

  Future<bool?> unstage() async {
    if (!_staged) {
      return null;
    }
    GitRemoveCallback? result =
        await GitRepoManager.getInstance().unstage(_file.path);
    if (result == null || result.result == GitAddResult.Fail) {
      return false;
    }
    return true;
  }

  Future<bool?> restore() async {
    if (_staged) {
      return null;
    }
    GitRestoreCallback? result =
        await GitRepoManager.getInstance().restore(_file.path);
    if (result == null || result.result == GitRestoreResult.Fail) {
      return false;
    }
    return true;
  }
}

class _PushAndCommitBottomSheet extends StatefulWidget {
  const _PushAndCommitBottomSheet();

  @override
  State<_PushAndCommitBottomSheet> createState() =>
      __PushAndCommitBottomSheetState();
}

class __PushAndCommitBottomSheetState extends State<_PushAndCommitBottomSheet> {
  void push() async {
    setState(() {
      loading = true;
    });

    await GitRepoManager.getInstance().push();
    setState(() {
      loading = false;
    });
  }

  void commit() async {
    setState(() {
      loading = true;
    });
    String commitMessage = _commitMessageController.text == ""
        ? "Commit from GitNotes at ${DateTime.now().toLocal().toIso8601String()}"
        : _commitMessageController.text;
    await GitRepoManager.getInstance().commit(commitMessage);
    setState(() {
      loading = false;
    });
  }

  StateHelper _helper = StateHelper.none;

  final TextEditingController _commitMessageController =
      TextEditingController();

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return FutureBuilder(
      future: GitRepoManager.getInstance().checkCommitAndPush(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.commitAllowed && snapshot.data!.pushAllowed) {
            _helper = StateHelper.commitAndPush;
          } else if (snapshot.data!.commitAllowed &&
              !snapshot.data!.pushAllowed) {
            _helper = StateHelper.commit;
          } else if (!snapshot.data!.commitAllowed &&
              snapshot.data!.pushAllowed) {
            _helper = StateHelper.push;
          } else {
            _helper = StateHelper.none;
          }
        } else {
          return const SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        switch (_helper) {
          case StateHelper.commit:
            return SizedBox(
              height: 300,
              child: commitUi(),
            );
          case StateHelper.push:
            return SizedBox(
              height: 300,
              child: pushUi(),
            );
          case StateHelper.commitAndPush:
            return SizedBox(
              height: 300,
              child: Column(
                children: [
                  commitUi(),
                  const Divider(
                    thickness: 2,
                    height: 20,
                  ),
                  pushUi(),
                ],
              ),
            );
          case StateHelper.none:
            return const SizedBox(
              height: 300,
              child: Center(
                child: Text(
                  "No files to commit and no commits to push.",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            );
        }
      },
    );
  }

  InkWell pushUi() {
    return InkWell(
      onTap: () {
        push();
      },
      child: SizedBox(
        height: 80,
        child: Container(
          width: MediaQuery.sizeOf(context).width < 500
              ? MediaQuery.sizeOf(context).width
              : 500,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Theme.of(context).colorScheme.tertiaryContainer),
          child: Center(
            child: Text(
              "Push",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onTertiaryContainer),
            ),
          ),
        ),
      ),
    );
  }

  Widget commitUi() {
    return Column(
      children: [
        Center(
          child: TextFormField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(20),
              label: const Text("Commit Message"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  width: 2,
                ),
              ),
            ),
            controller: _commitMessageController,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "*Default message will be used if not commit message is provided.",
          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            commit();
          },
          child: Container(
            height: 80,
            width: MediaQuery.sizeOf(context).width < 500
                ? MediaQuery.sizeOf(context).width
                : 500,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).colorScheme.primaryContainer),
            child: Center(
              child: Text(
                "Commit",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum StateHelper { commit, push, commitAndPush, none }
