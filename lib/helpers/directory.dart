import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DirectoryHelper {
  // singleton: private constructor and static instance
  static DirectoryHelper? _instance;

  DirectoryHelper._(this._homeDir)
      : _appDataDir = Directory("${_homeDir.path}/.GitNotes"),
        _notesDir = Directory("${_homeDir.path}/Notes");

  /// Returns an instance of the [DirectoryHelper],
  /// It creates the following directories in the directory selected by the user:
  ///   /GitNotes
  ///   /GitNotes/.GitNotes
  ///   /GitNotes/Notes
  static Future<DirectoryHelper> getInstance() async {
    if (_instance == null) {
      await Permission.manageExternalStorage.request();
      await Permission.storage.request();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? homePath = prefs.getString("_homeDir");

      if (homePath == null) {
        homePath = await FilePicker.platform.getDirectoryPath();
        if (homePath == null) {
          return DirectoryHelper.getInstance();
        }
        homePath = "$homePath/GitNotes";
        await prefs.setString("_homeDir", homePath);
      }
      Directory homeDir = await Directory(homePath).create(recursive: true);
      _instance = DirectoryHelper._(homeDir);
    }
    return _instance!;
  }

  Directory _homeDir;
  Directory _appDataDir;
  final Directory _notesDir;

  /// Returns the directory location of the /GitNotes/Notes directory
  /// It contains the main notes content
  Directory getNotesDirectory() {
    return _notesDir;
  }

  /// Prepares the /GitNotes directory for a clone
  /// Wipes all the data clean, any unsaved data will be lost.
  /// The repo will be cloned into /GitNotes
  Future<String> prepareForClone() async {
    await _homeDir.delete(recursive: true);
    await _homeDir.create(recursive: true);
    return _homeDir.path;
  }

  /// Returns the /GitNotes/.git directory.
  Directory getGitDirectory() {
    return Directory("$_homeDir/.git");
  }
}
