import 'dart:io';

import 'package:flutter/material.dart';
import 'package:git_notes/helpers/git/git_repo.dart';
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

  ListView homeStatusStatus() {
    return ListView.builder(
      itemCount: changed.length + staged.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text("Staged");
        }
        index -= 1;
        if (index < staged.length) {
          return stagedBox(staged[index]);
        }
        index -= staged.length;
        if (index == 0) {
          return Text("Changed");
        }
        index -= 1;
        if (index < changed.length) {
          return chanedBox(changed[index]);
        }
        return Container();
      },
    );
  }

  Widget stagedBox(FileStatusData statusData) {
    return SizedBox(
      height: 45,
      child: Row(
        children: [
          Text(
            statusData._changeChar,
            style: TextStyle(
              color: statusData.getChangedCharColor(),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(statusData.getFileName()),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: stage file
            },
            icon: const Icon(Icons.remove),
          )
        ],
      ),
    );
  }

  Widget chanedBox(FileStatusData statusData) {
    return SizedBox(
      height: 45,
      child: Row(
        children: [
          Text(
            statusData._changeChar,
            style: TextStyle(
              color: statusData.getChangedCharColor(),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(statusData.getFileName()),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: revert file
            },
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            onPressed: () {
              // TODO: stage file
            },
            icon: const Icon(Icons.add),
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

  void stage() {
    if (_staged) {
      return;
    } else {
      // TODO: stage the file
    }
  }

  void unstage() {
    if (!_staged) {
      return;
    } else {
      // TODO: unstage this file
    }
  }

  void revertChanges() {
    // TODO: rever the changes in this file
  }
}
