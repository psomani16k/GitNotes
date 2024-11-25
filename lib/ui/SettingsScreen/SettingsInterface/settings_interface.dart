import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

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
            onTap: () {
              // TODO: change theme
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
            onTap: () {
              // TODO: change theme
            },
            minVerticalPadding: 25,
            leading: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(MaterialCommunityIcons.format_color_fill),
            ),
            title: const Text("Custom Accent Color"),
            subtitle: const Text("Wallpaper Color or Custom Color"),
            trailing: Switch(value: true, onChanged: (value) {}),
          ),
          ListTile(
            onTap: () {
              // TODO: change theme
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
            onTap: () {
              // TODO: change theme
            },
            minVerticalPadding: 25,
            leading: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(MaterialCommunityIcons.folder_hidden),
            ),
            title: const Text("Show Hidden Folders"),
            subtitle: const Text("Show Hidden Content in Explorer"),
            trailing: Switch(value: true, onChanged: (value) {}),
          ),
          ListTile(
            onTap: () {
              // TODO: change theme
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
