import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_notes/helpers/ui_helper.dart';
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
  }

  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  // State variables
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: BlocConsumer<GitConfigurationBloc, GitConfigurationState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          // Loading
          if (state is GitConfigurationCloneLoadingState) {
            print("Loading State..........");
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text("Cloning..."),
                  ],
                ),
              ),
            );
          }

          // Clone fail
          if (state is GitConfigurationCloneFailState) {
            return Scaffold(
              body: Center(
                // TODO: make this look good
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Clone Failed",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                      width: UiHelper.minWidth(context, 129, widthFactor: 0.8),
                    ),
                    Text(state.error)
                  ],
                ),
              ),
            );
          }

          // Clone successful
          if (state is GitConfigurationCloneSuccessState) {
            return Scaffold(
              body: Center(
                // TODO: make this look good
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Cloned Successfully",
                      style: TextStyle(
                        color: Colors.green.shade500,
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                      width: UiHelper.minWidth(context, 129, widthFactor: 0.8),
                    ),
                    Text(state.repoName),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Continue",
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            body: Center(
              child: SizedBox(
                width: UiHelper.minWidth(context, 300, widthFactor: 0.9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        labelText: "URL",
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        labelText: "Auth Code (optional)",
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _userNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        labelText: "E-mail ID",
                      ),
                    ),
                    const SizedBox(height: 48),
                    FilledButton(
                      onPressed: () {
                        _bloc.add(
                          GitConfigurationCloneRepoEvent(
                            url: _urlController.text,
                            userName: _userNameController.text,
                            authCode: _passwordController.text,
                          ),
                        );
                      },
                      child: const Text(
                        "Clone and Continue",
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
