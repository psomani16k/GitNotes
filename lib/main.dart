import 'package:flutter/material.dart';
import 'package:git_notes/helpers/git/git_repo_manager.dart';
import 'package:git_notes/ui/HomeScreen/home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rinf/rinf.dart';
import './messages/generated.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeRust(assignRustSignal);
  await GitRepoManager.init();
  runApp(const EntryPoint());
}

class EntryPoint extends StatelessWidget {
  const EntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: lightDynamic,
            textTheme: GoogleFonts.montserratTextTheme(),
          ),
          darkTheme: ThemeData(colorScheme: darkDynamic),
          home: const Home(),
        );
      },
    );
  }
}
