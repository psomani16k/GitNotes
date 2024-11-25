import 'package:git_notes/helpers/settings/interface_settings.dart';

class SettingsHelper {
  static SettingsHelper? _instance;
  InterfaceSettings interfaceSettings;

  SettingsHelper._(this.interfaceSettings);

  static Future<void> init() async {
    List listOfSettings = await Future.wait([
      InterfaceSettings.init(),
    ]);

    _instance = SettingsHelper._(listOfSettings[0]);
  }

  SettingsHelper getInstance() {
    return _instance!;
  }
}
