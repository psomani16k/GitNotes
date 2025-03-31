import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:git_notes/helpers/settings/interface_settings.dart';
import 'package:git_notes/helpers/settings/settings_helper.dart';

class SettingsInterface extends StatefulWidget {
  const SettingsInterface({super.key});

  @override
  State<SettingsInterface> createState() => _SettingsInterfaceState();
}

class _SettingsInterfaceState extends State<SettingsInterface> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Interface"),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () async {
              await showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SizedBox(
                    height: 300,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        ListTile(
                          onTap: () {
                            SettingsHelper.getInstance()
                                .interfaceSettings
                                .setTheme(AppTheme.light);
                            Navigator.pop(context);
                          },
                          leading: Radio(
                            value: AppTheme.light,
                            onChanged: (value) {},
                            groupValue: SettingsHelper.getInstance()
                                .interfaceSettings
                                .getThemeRaw(),
                          ),
                          title: const Text("Light"),
                        ),
                        ListTile(
                          onTap: () {
                            SettingsHelper.getInstance()
                                .interfaceSettings
                                .setTheme(AppTheme.dark);
                            Navigator.pop(context);
                          },
                          leading: Radio(
                            value: AppTheme.dark,
                            onChanged: (value) {},
                            groupValue: SettingsHelper.getInstance()
                                .interfaceSettings
                                .getThemeRaw(),
                          ),
                          title: const Text("Dark"),
                        ),
                        ListTile(
                          onTap: () {
                            SettingsHelper.getInstance()
                                .interfaceSettings
                                .setTheme(AppTheme.black);
                            Navigator.pop(context);
                          },
                          leading: Radio(
                            value: AppTheme.black,
                            onChanged: (value) {},
                            groupValue: SettingsHelper.getInstance()
                                .interfaceSettings
                                .getThemeRaw(),
                          ),
                          title: const Text("Black"),
                        ),
                        ListTile(
                          onTap: () {
                            SettingsHelper.getInstance()
                                .interfaceSettings
                                .setTheme(AppTheme.system);
                            Navigator.pop(context);
                          },
                          leading: Radio(
                            value: AppTheme.system,
                            onChanged: (value) {},
                            groupValue: SettingsHelper.getInstance()
                                .interfaceSettings
                                .getThemeRaw(),
                          ),
                          title: const Text("System"),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            minVerticalPadding: 25,
            leading: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.brightness_4),
            ),
            title: const Text("Theme"),
            subtitle: const Text("Light, Dark or Black"),
          ),
          ListTile(
            enableFeedback: false,
            minVerticalPadding: 25,
            leading: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(MaterialCommunityIcons.format_color_fill),
            ),
            title: const Text("Custom Accent Color"),
            subtitle: const Text("Wallpaper Color or Custom Color"),
            trailing: Switch(
              value: SettingsHelper.getInstance()
                  .interfaceSettings
                  .getCustomAccentColor(),
              onChanged: (value) {
                setState(() {
                  SettingsHelper.getInstance()
                      .interfaceSettings
                      .setCustomAccentColor(value);
                });
              },
            ),
          ),
          ListTile(
            onTap: () async {
              // await showModalBottomSheet(
              //   context: context,
              //   builder: (context) {},
              // ); //
            },
            minVerticalPadding: 25,
            leading: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.color_lens),
            ),
            title: const Text("Accent Color"),
            subtitle: const Text("Main color of the UI"),
            trailing: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.red,
              ),
            ),
          ),
          ListTile(
            enableFeedback: false,
            minVerticalPadding: 25,
            leading: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(MaterialCommunityIcons.folder_hidden),
            ),
            title: const Text("Show Hidden Folders"),
            subtitle: const Text("Show Hidden Content in Explorer"),
            trailing: Switch(
              value: SettingsHelper.getInstance()
                  .interfaceSettings
                  .getShowHiddenFolders(),
              onChanged: (value) {
                setState(() {
                  SettingsHelper.getInstance()
                      .interfaceSettings
                      .setShowHiddenFolders(value);
                });
              },
            ),
          ),
          ListTile(
            onTap: () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (context) {
                  return const _InterfaceFontPopup();
                },
              );
            },
            minVerticalPadding: 25,
            leading: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(MaterialCommunityIcons.format_font),
            ),
            title: const Text("App Wide Font"),
            subtitle: const Text("Doesn't affect Markdown font"),
          ),
        ],
      ),
    );
  }
}

class _InterfaceFontPopup extends StatefulWidget {
  const _InterfaceFontPopup({super.key});

  @override
  State<_InterfaceFontPopup> createState() => __InterfaceFontPopupState();
}

class __InterfaceFontPopupState extends State<_InterfaceFontPopup> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary,
                      blurRadius: 5,
                      blurStyle: BlurStyle.outer,
                    )
                  ],
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(25),
                    child: Icon(Icons.font_download_rounded),
                  ),
                  Column(
                    children: [
                      Text(
                        SettingsHelper.getInstance()
                            .interfaceSettings
                            .getFontName(),
                        style: SettingsHelper.getInstance()
                            .interfaceSettings
                            .getFont(
                              Theme.of(context).textTheme.headlineSmall!,
                            ),
                      ),
                      Text(
                        "The quick brown fox jumps over the lazy dog.",
                        style: SettingsHelper.getInstance()
                            .interfaceSettings
                            .getFont(
                              Theme.of(context).textTheme.bodyMedium!,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(),
          ],
        ),
      ),
    );
  }
}
