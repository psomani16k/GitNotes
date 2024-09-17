import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_notes/ui/GitConfigurationScreen/bloc/git_configuration_bloc.dart';

class GitConfigurationScreen extends StatefulWidget {
  const GitConfigurationScreen({super.key});

  @override
  State<GitConfigurationScreen> createState() => _GitConfigurationScreenState();
}

class _GitConfigurationScreenState extends State<GitConfigurationScreen> {
  late GitConfigurationBloc _bloc;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = GitConfigurationBloc();
    _bloc.add(GitConfigurationInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: BlocConsumer<GitConfigurationBloc, GitConfigurationState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          return Container();
        },
      ),
    );
  }
}
