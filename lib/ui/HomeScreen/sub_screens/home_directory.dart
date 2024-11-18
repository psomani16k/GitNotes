import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
    if (mounted) {
      setState(() {
        loading = true;
      });
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
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  List<File> fileEntities = [];
  List<Directory> directoryEntities = [];
  bool updated = false;
  bool shouldPop = false;
  bool loading = true;
  Directory? currentDirectory;

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
          populateData();
          return;
        }
      },
      child: VisibilityDetector(
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.1 && !updated) {
            print("1");
            populateData();
            updated = true;
          } else {
            print("2");
            updated = false;
          }
        },
        key: const Key("home-directory"),
        child: loading
            ? const LinearProgressIndicator()
            : homeDirectoryDirectory(),
      ),
    );
  }

  ListView homeDirectoryDirectory() {
    return ListView.builder(
      itemCount: fileEntities.length + directoryEntities.length,
      itemBuilder: (context, index) {
        if (index < directoryEntities.length) {
          return directoryBox(directoryEntities[index]);
        } else {
          index = index - directoryEntities.length;
          return fileBox(fileEntities[index]);
        }
      },
    );
  }

  Widget directoryBox(Directory dir) {
    String name = dir.path.split("/").last;
    return InkWell(
      onTap: () {
        setState(() {
          currentDirectory = dir;
          populateData();
        });
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
                Text(name),
              ],
            ),
            const Spacer(),
            const Divider(
              thickness: 1,
              height: 1,
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
      onTap: () {
        // TODO: open the file
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
                Text(name),
              ],
            ),
            const Spacer(),
            const Divider(
              thickness: 1,
              height: 1,
            )
          ],
        ),
      ),
    );
  }
}
