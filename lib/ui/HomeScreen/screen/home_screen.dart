import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:git_notes/helpers/animations.dart';
import 'package:git_notes/ui/GitConfigurationScreen/screen/git_configuration_screen.dart';
import 'package:git_notes/ui/HomeScreen/bloc/home_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = HomeBloc();
    _bloc.add(HomeInitialEvent());
  }

  static const Map<String, Icon> _icons = {};
  List<File> fileEntities = [];
  List<Directory> directoryEntities = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("git_notes"),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.gite),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.abc),
              ),
            ],
          ),
          body: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
