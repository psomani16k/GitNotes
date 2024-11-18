import 'dart:io';

import 'package:flutter/material.dart';
import 'package:git_notes/helpers/git/git_repo.dart';
import 'package:git_notes/helpers/git/git_repo_manager.dart';
import 'package:git_notes/messages/git_add.pb.dart';
import 'package:git_notes/messages/git_status.pb.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeStatus extends StatefulWidget {
  const HomeStatus({super.key, required this.repo});
  final GitRepo? repo;
  @override
  State<HomeStatus> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<HomeStatus> {
  @override
  void didUpdateWidget(covariant HomeStatus oldWidget) {
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
      itemCount: changed.length + staged.length + 2,
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
        return Container();
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
              Text(statusData.getFileName()),
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
              Text(statusData.getFileName()),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  // TODO: rever file
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

  void revertChanges() {
    // TODO: rever the changes in this file
  }
}
