import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DirectoryHelper {
  // singleton: private constructor and static instance
  static DirectoryHelper? _instance;

  DirectoryHelper._(this._homeDir);

  /// Returns an instance of the [DirectoryHelper],
  /// It creates a folder named GitNotes where everything will be stored.
  static Future<DirectoryHelper> getInstance() async {
    if (_instance == null) {
      Directory homeDir = (await getExternalStorageDirectory())!;
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
