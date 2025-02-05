import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:git_notes/ui/HomeScreens/HomeDirectory/bloc/home_directory_bloc.dart';
import 'package:git_notes/ui/MarkdownRendering/screen/markdown_rendering_screen.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeDirectory extends StatefulWidget {
  const HomeDirectory({super.key});

  @override
  State<HomeDirectory> createState() => _HomeDirectoryState();
}

class _HomeDirectoryState extends State<HomeDirectory> {
// Page data

  List<File>? fileEntities;
  List<Directory>? directoryEntities;
  bool reverseAnimation = false;
  Directory? currentDirectory;

  @override
  Widget build(BuildContext context) {
    HomeDirectoryBloc bloc = BlocProvider.of<HomeDirectoryBloc>(context);
    return BlocConsumer<HomeDirectoryBloc, HomeDirectoryState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is HomeDirectoryShowSnackbarState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
          ));
        }
      },
      builder: (context, state) {
        // this is where bloc comes
        if (state is HomeDirectoryInitial) {
          bloc.add(HomeDirectoryRepoUpdateEvent());
        }

        if (state is HomeDirectorySetDirectoryState) {
          currentDirectory = state.currentDirectory;
          fileEntities = state.fileEntities;
          directoryEntities = state.directoryEntities;
          reverseAnimation = state.reverse;
        }

        if (state is HomeDirectoryExitAppState) {
          SystemNavigator.pop(animated: true);
        }

        if (directoryEntities == null ||
            fileEntities == null ||
            currentDirectory == null) {
          return Center(
            child: Text(
              "Please clone a repository to continue.",
              style: TextTheme.of(context).labelLarge,
            ),
          );
        }

        return VisibilityDetector(
          onVisibilityChanged: (info) {
            if (info.visibleFraction >= 0.1) {
              bloc.add(HomeDirectoryUpdateDirectoryInfoEvent());
            }
          },
          key: const Key("home-directory"),
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              bloc.add(HomeDirectoryBackPressEvent());
            },
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
                key: ValueKey(currentDirectory),
                child: ListView.builder(
                  itemCount:
                      fileEntities!.length + directoryEntities!.length + 1,
                  itemBuilder: (context, index) {
                    if (index < directoryEntities!.length) {
                      return _HomeDirectoryDirectoryWidget(
                          dir: directoryEntities![index]);
                    }
                    index = index - directoryEntities!.length;
                    if (index < fileEntities!.length) {
                      return _HomeDirectoryFileWidget(
                          file: fileEntities![index]);
                    }
                    return const SizedBox(height: 90);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeDirectoryDirectoryWidget extends StatelessWidget {
  final Directory dir;
  const _HomeDirectoryDirectoryWidget({required this.dir});

  @override
  Widget build(BuildContext context) {
    String name = dir.path.split("/").last;
    return InkWell(
      onTap: () {
        BlocProvider.of<HomeDirectoryBloc>(context)
            .add(HomeDirectoryChooseDirectoryEvent(dir: dir));
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
                    style: TextTheme.of(context).titleSmall,
                    pauseBetween: const Duration(seconds: 4),
                    fadedBorder: true,
                    velocity:
                        const Velocity(pixelsPerSecond: const Offset(40, 0)),
                    mode: TextScrollMode.bouncing,
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

class _HomeDirectoryFileWidget extends StatelessWidget {
  final File file;
  _HomeDirectoryFileWidget({required this.file});

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
    "sh": Ionicons.terminal,
  };
  @override
  Widget build(BuildContext context) {
    String name = file.path.split("/").last;
    String extension = name.split(".").last;
    return InkWell(
      onTap: () async {
        if (extension == "md") {
          Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => MarkdownRenderingScreen(file: file),
          ));
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
                    name,
                    mode: TextScrollMode.bouncing,
                    style: TextTheme.of(context).titleSmall,
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
