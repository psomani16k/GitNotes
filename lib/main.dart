import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_notes/helpers/git/git_repo.dart';
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
  GitRepo.init();
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
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: lightDynamic,
            textTheme: TextTheme(
              // Large, display text, typically for very prominent text.
              displayLarge: GoogleFonts.montserrat(
                fontSize: 57,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.25,
              ),
              displayMedium: GoogleFonts.montserrat(
                fontSize: 45,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
              displaySmall: GoogleFonts.montserrat(
                fontSize: 36,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
              // For larger headlines, typically for section titles.
              headlineLarge: GoogleFonts.roboto(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
              headlineMedium: GoogleFonts.roboto(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.15,
              ),
              headlineSmall: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
              // For titles and smaller headlines.
              titleLarge: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
              titleMedium: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.15,
              ),
              titleSmall: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              // For body text in various sizes.
              bodyLarge: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
              bodyMedium: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.25,
              ),
              bodySmall: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.4,
              ),
              // For labels and buttons.
              labelLarge: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.25,
              ),
              labelMedium: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
              labelSmall: GoogleFonts.roboto(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
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
