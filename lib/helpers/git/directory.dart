import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class DirectoryHelper {
  // singleton: private constructor and static instance
  static DirectoryHelper? _instance;

  DirectoryHelper._(this._homeDir);

  /// Returns an instance of the [DirectoryHelper],
  /// It creates a folder named GitNotes where everything will be stored.
  static Future<DirectoryHelper> init() async {
    // TODO: make an onboarding screen for this process
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }
    if (_instance == null) {
      String? homeDirPath =
          await const FlutterSecureStorage().read(key: "home_dir");
      homeDirPath ??= await FilePicker.platform.getDirectoryPath();
      if (homeDirPath == null) {
        return init();
      }
      const FlutterSecureStorage().write(key: "home_dir", value: homeDirPath);
      _instance = DirectoryHelper._(Directory(homeDirPath));
    }
    return _instance!;
  }

  /// Returns the singleton instance of [DirectoryHelper].
  /// Will throw error if init() isn't called before calling this
  static DirectoryHelper getInstance() {
    return _instance!;
  }

  final Directory _homeDir;

  /// Returns the home directory for the app
  Directory getHomeDirectory() {
    return _homeDir;
  }
}
