import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:git_notes/helpers/git/git_repo.dart';
import 'package:git_notes/helpers/ui_helper.dart';
import 'package:git_notes/ui/GitConfigurationScreen/screen/git_configuration_screen.dart';
import 'package:git_notes/ui/HomeScreen/bloc/home_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // HomeBloc variable
  late HomeBloc _bloc;

// Helping functions
  @override
  void initState() {
    super.initState();
    _bloc = HomeBloc();
    _bloc.add(HomeInitialEvent());
  }

// Page data
  Map<String, IconData> fileIcons = {
    "md": MaterialCommunityIcons.language_markdown,
    "pdf": MaterialCommunityIcons.file_pdf_box,
    "xlss": MaterialCommunityIcons.google_spreadsheet,
    "jpg": MaterialCommunityIcons.file_jpg_box,
    "png": MaterialCommunityIcons.file_png_box
  };

// Page State data
  List<File> fileEntities = [];

  List<Directory> directoryEntities = [];

  List<GitRepo> repoEntities = [];

  GitRepo? currentRepo;

  Directory? currentDirectory;

  @override
  Widget build(BuildContext context) {
    double drawerWidth = UiHelper.minWidth(context, 350, widthFactor: 0.8);
    return BlocProvider(
      create: (context) => _bloc,
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          // initial state
          if (state is HomeInitialState) {
            print("initial state");
            repoEntities = state.repoEntities;
            directoryEntities = state.directoryEntities;
            fileEntities = state.fileEntities;
            currentRepo = state.initialRepo;
          }

          // no repo state
          if (state is HomeNoRepoState) {
            print("no repo state");
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
          }
          return Scaffold(
            drawerEnableOpenDragGesture: false,
            drawer: Drawer(
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
                                // TODO: Select this repo to navigate
                                Scaffold.of(context).closeDrawer();
                                _bloc.add(
                                    HomeChooseRepoEvent(repoEntities[index]));
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
                                builder: (context) =>
                                    const GitConfigurationScreen()),
                          );
                        },
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 16),
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 16),
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 20),
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
            ),
            appBar: AppBar(
              title: Text(
                  (currentRepo != null) ? currentRepo!.repoId! : "GitNotes"),
              actions: [
                IconButton(
                  onPressed: () {
                    // TODO: implement commit and push
                  },
                  icon: const Icon(Icons.upload_rounded),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: implement fetch and merge / reclone
                  },
                  icon: const Icon(Icons.download_rounded),
                ),
                const SizedBox(
                  width: 5,
                )
              ],
            ),
            body: ListView.builder(
              itemCount: fileEntities.length + directoryEntities.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: (index < directoryEntities.length)
                      ? directoryBox(context, directoryEntities[index])
                      : fileBox(context,
                          fileEntities[index - directoryEntities.length]),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget directoryBox(BuildContext context, Directory dir) {
    String dirName = dir.path.split("/").last;
    return InkWell(
      onTap: () {
        // TODO: open the folder
        _bloc.add(HomeChooseDirectoryEvent(dir));
      },
      radius: 20,
      borderRadius: BorderRadius.circular(20),
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
    return InkWell(
      onTap: () {
        // TODO: open the file
      },
      radius: 20,
      borderRadius: BorderRadius.circular(20),
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
