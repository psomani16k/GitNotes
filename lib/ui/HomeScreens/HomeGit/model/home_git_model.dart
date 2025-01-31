import 'package:flutter/material.dart';
import 'package:git_notes/messages/git_status.pb.dart';

class FileStatusData {
  String relativeFilePath;
  bool staged;
  Status status;

  FileStatusData._(this.relativeFilePath, this.status, this.staged);

  factory FileStatusData(GitFileStatus fileStatus) {
    bool isStaged = (fileStatus.status == Status.IndexModified ||
        fileStatus.status == Status.IndexNew ||
        fileStatus.status == Status.IndexDeleted ||
        fileStatus.status == Status.IndexRenamed ||
        fileStatus.status == Status.IndexTypechange);

    return FileStatusData._(fileStatus.file, fileStatus.status, isStaged);
  }

  String getFileName() {
    return relativeFilePath.split("/").last;
  }

  String getChangeChar() {
    switch (status) {
      case Status.IndexDeleted:
        return "D";
      case Status.IndexModified:
        return "M";
      case Status.IndexNew:
        return "N";
      case Status.IndexRenamed:
        return "R";
      case Status.IndexTypechange:
        return "T";
      case Status.WorkTreeDeleted:
        return "D";
      case Status.WorkTreeModified:
        return "M";
      case Status.WorkTreeNew:
        return "N";
      case Status.WorkTreeRenamed:
        return "R";
      case Status.WorkTreeTypechange:
        return "T";
    }
    return "";
  }

  Color getChangedCharColor() {
    String char = getChangeChar();
    if (char == "N") {
      return Colors.green;
    } else if (char == "M") {
      return Colors.yellow;
    } else if (char == "D") {
      return Colors.red;
    } else if (char == "R") {
      return Colors.lightGreen;
    } else {
      return Colors.blue;
    }
  }
}
