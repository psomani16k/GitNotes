import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_notes/helpers/directory.dart';
import 'package:git_notes/helpers/git/git_repo.dart';
import 'package:git_notes/helpers/git/repo_storage.dart';
import 'package:git_notes/ui/GitConfigurationScreen/bloc/git_configuration_bloc.dart';
import 'package:git_notes/ui/HomeScreen/bloc/home_bloc.dart';
import 'package:git_notes/ui/HomeScreen/screen/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rinf/rinf.dart';
import './messages/generated.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeRust(assignRustSignal);
  await RepoStorage.init();
  await DirectoryHelper.init();
  await GitRepo.init();
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
          home: MultiBlocProvider(
            providers: [
              BlocProvider<HomeBloc>(
                create: (context) => HomeBloc(),
              ),
              BlocProvider(
                create: (context) => GitConfigurationBloc(),
              ),
            ],
            child: const HomeScreen(),
          ),
        );
      },
    );
  }
}
