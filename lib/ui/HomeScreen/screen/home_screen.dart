import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:git_notes/helpers/git/git_repo.dart';
import 'package:git_notes/helpers/ui_helper.dart';
import 'package:git_notes/messages/status.pbserver.dart';
import 'package:git_notes/ui/GitConfigurationScreen/bloc/git_configuration_bloc.dart';
import 'package:git_notes/ui/GitConfigurationScreen/screen/git_configuration_screen.dart';
import 'package:git_notes/ui/HomeScreen/bloc/home_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:git_notes/ui/HomeScreen/screen/status_screen.dart';
import 'package:git_notes/ui/MarkdownRendering/screen/markdown_rendering_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
// Bloc variable
  late HomeBloc _bloc;
// Page data
  Map<String, IconData> fileIcons = {
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

  Duration animationDuration = Durations.short2;

// Page State data
  int pageIndex = 0;

  List<File> fileEntities = [];

  List<Directory> directoryEntities = [];

  List<GitRepo> repoEntities = [];

  GitRepo? currentRepo;

  bool canPop = true;

  double animationValue = 1;

  @override
  Widget build(BuildContext context) {
    _bloc = context.read<HomeBloc>();
    _bloc.add(HomeInitialEvent());
    double drawerWidth = UiHelper.minWidth(context, 350, widthFactor: 0.8);
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeBackCloseState) {
          canPop = true;
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Press again to exit.")));
        }
        if (state is HomePullSingleRepoResultState) {
          showDialog(
              context: context,
              builder: (context) {
                return Text(state.callback.data);
              });
        }
      },
      builder: (context, state) {
        // loading state
        if (state is HomeLoadingState) {}

        // initial state
        if (state is HomeInitialState) {
          repoEntities = state.repoEntities;
          directoryEntities = state.directoryEntities;
          fileEntities = state.fileEntities;
          currentRepo = state.initialRepo;
        }

        // no repo state
        if (state is HomeNoRepoState) {
          // TODO: display something to inform the user that
        }

        // update currentRepo to a newly choosen repo
        if (state is HomeUpdateCurrentRepoState) {
          currentRepo = state.newRepo;
          fileEntities = state.fileEntities;
          directoryEntities = state.directoryEntities;
        }

        // updates the list of files and directory when chooseing a directory
        if (state is HomeUpdateDirectoryState) {
          fileEntities = state.fileEntities;
          directoryEntities = state.directoryEntities;
          animationValue = 1;
          canPop = false;
        }

        // changes the animationValue to trigger the animation
        if (state is HomeTriggerAnimationState) {
          animationValue = 0;
        }
        return PopScope(
          canPop: canPop,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              canPop = false;
              return;
            }
            _bloc.add(HomeBackPressEvent());
          },
          child: Scaffold(
            drawerEnableOpenDragGesture: false,
            drawer: homeDrawer(drawerWidth),
            appBar: homeAppBar(context),
            bottomNavigationBar: NavigationBar(
              destinations: const [
                NavigationDestination(
                  icon: Icon(MaterialCommunityIcons.folder),
                  label: "Directory",
                ),
                NavigationDestination(
                  icon: Icon(MaterialCommunityIcons.git),
                  label: "Status",
                )
              ],
              selectedIndex: pageIndex,
              onDestinationSelected: (value) {
                if (currentRepo != null && value == 1) {
                  GetStatus(repoDirectory: currentRepo!.getDirectory().path)
                      .sendSignalToRust();
                }
                setState(() {
                  pageIndex = value;
                });
              },
            ),
            body: [homeDirectory(), StatusScreen()][pageIndex],
          ),
        );
      },
    );
  }

  AnimatedOpacity homeDirectory() {
    return AnimatedOpacity(
      opacity: animationValue,
      duration: animationDuration,
      curve: Easing.standardDecelerate,
      child: ListView.builder(
        itemCount: 1 + fileEntities.length + directoryEntities.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            return AnimatedContainer(
              duration: animationDuration,
              curve: Easing.legacyDecelerate,
              height: 100 * (1 - animationValue),
            );
          }
          index -= 1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: (index < directoryEntities.length)
                ? directoryBox(context, directoryEntities[index])
                : fileBox(
                    context, fileEntities[index - directoryEntities.length]),
          );
        },
      ),
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
                  itemCount: repoEntities.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Scaffold.of(context).closeDrawer();
                        _bloc.add(HomeChooseRepoEvent(repoEntities[index]));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 42,
                          top: 16,
                          bottom: 16,
                        ),
                        child: Text(repoEntities[index].getRepoId()),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              // builder added to provide a new context with access to Scaffold.of(context)
              InkWell(
                onTap: () {
                  // TODO: add a new repo
                  Scaffold.of(context).closeDrawer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (context) => GitConfigurationBloc(),
                          ),
                          BlocProvider.value(
                            value: _bloc,
                          ),
                        ],
                        child: const GitConfigurationScreen(),
                      ),
                    ),
                  );
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
              InkWell(
                onTap: () {
                  // TODO: Perform a pull all on repositories
                },
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      child: Icon(
                        Icons.download_outlined,
                      ),
                    ),
                    Text("Pull All")
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

  AppBar homeAppBar(BuildContext context) {
    return AppBar(
      title: Text((currentRepo != null) ? currentRepo!.repoId! : "GitNotes"),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: implement commit and push
          },
          icon: const Icon(Icons.upload_rounded),
        ),
        IconButton(
          onPressed: () {
            if (currentRepo != null) {
              _bloc.add(HomeSinglePullEvent());
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please add a repository first"),
                ),
              );
            }
          },
          icon: const Icon(Icons.download_rounded),
        ),
        const SizedBox(
          width: 5,
        )
      ],
    );
  }

  Widget directoryBox(BuildContext context, Directory dir) {
    String dirName = dir.path.split("/").last;
    return GestureDetector(
      onTap: () {
        // TODO: open the folder
        _bloc.add(HomeChooseDirectoryEvent(dir));
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.secondaryContainer),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Icon(MaterialIcons.folder,
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
            Text(
              dirName,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
            )
          ],
        ),
      ),
    );
  }

  Widget fileBox(BuildContext context, File file) {
    String fileName = file.path.split("/").last;
    String extension = fileName.split(".").last;
    if (fileIcons.keys.contains(extension)) {
      fileName = fileName.substring(0, fileName.length - extension.length - 1);
    }
    return GestureDetector(
      onTap: () {
        // TODO: open the file
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MarkdownRenderingScreen(
              file: file,
            ),
          ),
        );
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.tertiaryContainer),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Icon(
                  fileIcons[extension] ??
                      MaterialCommunityIcons.file_document_outline,
                  color: Theme.of(context).colorScheme.onTertiaryContainer),
            ),
            Text(
              fileName,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiaryContainer),
            )
          ],
        ),
      ),
    );
  }
}
