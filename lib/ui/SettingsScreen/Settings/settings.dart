import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:git_notes/ui/SettingsScreen/SettingsInterface/settings_interface.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () async {
              await Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => const SettingsInterface(),
              ));
            },
            minVerticalPadding: 25,
            leading: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(MaterialCommunityIcons.cellphone),
            ),
            title: const Text("Interface"),
            subtitle: const Text("Theming and Customization"),
          ),
          ListTile(
            onTap: () async {
              await Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => const SettingsInterface(),
              ));
            },
            minVerticalPadding: 25,
            leading: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(FontAwesome5Brands.git_square),
            ),
            title: const Text("Git"),
            subtitle: const Text("Edit Git Defaults, Manage Repositories"),
          ),
          ListTile(
            onTap: () {},
            minVerticalPadding: 25,
            leading: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(MaterialCommunityIcons.language_markdown),
            ),
            title: const Text("Markdown"),
            subtitle: const Text("Change Markdown Configuration"),
          ),
          ListTile(
            onTap: () {},
            minVerticalPadding: 25,
            leading: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.error),
            ),
            title: const Text("About GitNotes"),
            subtitle: const Text("About the App, Licence, GitHub"),
          ),
        ],
      ),
    );
  }
}
