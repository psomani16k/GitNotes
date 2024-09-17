// import 'dart:convert';
// import 'dart:io';
// import 'package:gitnotes/helpers/directory.dart';

// class IconsInfoHelper {
//   DirectoryHelper _directoryHelper;
//   static IconsInfoHelper? _instance;

//   IconsInfoHelper._(this._directoryHelper);

//   static Future<IconsInfoHelper> getInstance() async {
//     if (_instance == null) {
//       DirectoryHelper helper = await DirectoryHelper.getInstance();
//       _instance = IconsInfoHelper._(helper);
//       _instance!.readIconData();
//     }
//     return _instance!;
//   }

//   Map<String, dynamic> _iconData = {};
//   File? _iconDataFile;

//   void readIconData() async {
//     _iconDataFile = await _directoryHelper.getIconsDataFile();
//     String iconData = await _iconDataFile!.readAsString();
//     _iconData = (jsonDecode(iconData) as Map<String, dynamic>);
//   }
// }
