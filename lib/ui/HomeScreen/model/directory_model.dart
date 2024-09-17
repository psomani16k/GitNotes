import 'dart:io';

import 'package:flutter/services.dart';
import 'package:git_notes/helpers/directory.dart';
import 'package:git_notes/helpers/git.dart';

class HomeDirectoryModel {
  DirectoryHelper _helper;
  Directory _currentDir;
  GitHelper? _gitHelper;

  HomeDirectoryModel(DirectoryHelper helper)
      : _helper = helper,
        _currentDir = helper.getNotesDirectory();

  /// Returns the contents of the Notes directory if it exists, null if there is no such directory.
  Future<List<FileSystemEntity>?> enlistNotesDirectoryContents() async {
    Directory notesDir = _helper.getNotesDirectory();
    if (await notesDir.exists()) {
      return notesDir.list(recursive: false, followLinks: false).toList();
    } else {
      return null;
    }
  }

  Future<List<FileSystemEntity>> enlistCurrentDirectoryContents() async {
    return _currentDir.list(recursive: false, followLinks: false).toList();
  }
}
