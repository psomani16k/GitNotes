import 'dart:io';

import 'package:flutter/material.dart';
import 'package:git_notes/messages/status.pbserver.dart';
import 'package:rinf/rinf.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final Stream<RustSignal<StatusCallBack>> statusCallback =
      StatusCallBack.rustSignalStream;

  List<FileStatusData> stagedFiles = [];

  List<FileStatusData> changedFile = [];

  void populateStatusData(List<String> statusData) {
    stagedFiles = [];
    changedFile = [];
    for (String status in statusData) {
      FileStatusData statusData = FileStatusData(status);
      if (statusData.isStaged()) {
        stagedFiles.add(statusData);
      } else {
        changedFile.add(statusData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: statusCallback,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> statusData = snapshot.data!.message.status;
          populateStatusData(statusData);
        }
        return ListView.builder(
          itemCount: changedFile.length,
          itemBuilder: (context, index) {
            return stagedFileBox(changedFile[index]);
          },
        );
      },
    );
  }
}

Widget stagedFileBox(FileStatusData statusData) {
  return Container(
    child: Row(
      children: [
        Container(
          height: 16,
          width: 16,
          child: Center(
            child: Text(statusData.getChangeChar()),
          ),
        ),
        Text(statusData.getFileName()),
        Spacer(),
        IconButton(
            onPressed: () {
              // TODO: implement "un-add"
            },
            icon: Icon(Icons.remove))
      ],
    ),
  );
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
    print(file.path);
    return FileStatusData._(file, changeChar, staged);
  }

  String getFileName() {
    return _file.path.split("/").last;
  }

  // TODO: find a way to get the relative path of this file
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
