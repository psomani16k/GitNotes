import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DirectoryHelper {
  // singleton: private constructor and static instance
  static DirectoryHelper? _instance;

  DirectoryHelper._(this._homeDir);

  /// Returns an instance of the [DirectoryHelper],
  /// It creates a folder named GitNotes where everything will be stored.
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

  final Directory _homeDir;

  /// Returns the home directory for the app
  Directory getHomeDirectory() {
    return _homeDir;
  }
}
