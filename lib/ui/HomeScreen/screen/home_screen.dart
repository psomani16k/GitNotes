import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:git_notes/ui/HomeScreen/bloc/home_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = HomeBloc();
    _bloc.add(HomeInitialEvent());
  }

  List<File> fileEntities = [
    File("something/markdown.md"),
    File("something/pdf file.pdf"),
    File("something/excel.xlss")
  ];
  List<Directory> directoryEntities = [
    Directory("something/folder 1"),
    Directory("something/folder 2")
  ];

  String? repoName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        child: Scaffold(
          drawer: Container(),
          appBar: AppBar(
            title: Text(repoName ?? "GitNotes"),
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
          body: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return ListView.builder(
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget directoryBox(BuildContext context, Directory dir) {
    String dirName = dir.path.split("/").last;
    return InkWell(
      onTap: () {
        // TODO: open the folder
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
              child: Icon(MaterialIcons.folder_open,
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
              child: Icon(MaterialIcons.folder_open,
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
