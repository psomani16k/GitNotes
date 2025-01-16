import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_notes/helpers/git/git_repo_manager.dart';
import 'package:git_notes/helpers/settings/settings_helper.dart';
import 'package:git_notes/ui/GitCloneScreen/bloc/git_clone_bloc.dart';
import 'package:git_notes/ui/HomeScreens/Home/bloc/home_bloc.dart';
import 'package:git_notes/ui/HomeScreens/Home/screen/home.dart';
import 'package:git_notes/ui/HomeScreens/HomeDirectory/bloc/home_directory_bloc.dart';
import 'package:git_notes/ui/HomeScreens/HomeGit/bloc/home_git_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rinf/rinf.dart';

import './messages/generated.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    initializeRust(assignRustSignal),
    GitRepoManager.init(),
    SettingsHelper.init(),
  ]);
  runApp(const EntryPoint());
}

class EntryPoint extends StatelessWidget {
  const EntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeBloc()),
        BlocProvider(create: (context) => HomeDirectoryBloc()),
        BlocProvider(create: (context) => HomeGitBloc()),
        BlocProvider(create: (context) => GitCloneBloc()),
      ],
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: lightDynamic,
              textTheme: GoogleFonts.montserratTextTheme(),
            ),
            darkTheme: ThemeData(
              colorScheme: darkDynamic,
            ),
            home: const Home(),
          );
        },
      ),
    );
  }
}
