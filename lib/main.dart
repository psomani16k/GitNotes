import 'package:flutter/material.dart';
import 'package:git_notes/ui/HomeScreen/screen/home_screen.dart';
import 'package:rinf/rinf.dart';
import './messages/generated.dart';
import 'package:dynamic_color/dynamic_color.dart';
// import 'package:gitnotes/ui/HomeScreen/screen/home_screen.dart';

void main(List<String> args) async {
  await initializeRust(assignRustSignal);
  runApp(const EntryPoint());
}

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  bool switchValue = false;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          theme: ThemeData(colorScheme: lightDynamic),
          darkTheme: ThemeData(colorScheme: darkDynamic),
          home: const HomeScreen(),
        );
      },
    );
  }
}
