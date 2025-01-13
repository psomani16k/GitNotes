import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_notes/helpers/ui_helper.dart';
import 'package:git_notes/ui/GitCloneScreen/bloc/git_clone_bloc.dart';

class GitCloneScreen extends StatefulWidget {
  const GitCloneScreen({super.key});

  @override
  State<GitCloneScreen> createState() => _GitCloneScreenState();
}

class _GitCloneScreenState extends State<GitCloneScreen> {
// data variables
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    GitCloneBloc bloc = BlocProvider.of<GitCloneBloc>(context);
    return BlocConsumer<GitCloneBloc, GitCloneState>(
      bloc: bloc,
      builder: (context, state) {
        // Loading
        if (state is GitCloneLoadingState) {
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
        if (state is GitCloneFailState) {
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
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 24,
                    width: UiHelper.minWidth(context, 129, widthFactor: 0.8),
                  ),
                  Text(state.error),
                  SizedBox(
                    height: 24,
                    width: UiHelper.minWidth(context, 129, widthFactor: 0.8),
                  ),
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

        // Clone successful
        if (state is GitCloneSuccessState) {
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
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 24,
                    width: UiHelper.minWidth(context, 129, widthFactor: 0.8),
                  ),
                  Text(state.path),
                  SizedBox(
                    height: 24,
                    width: UiHelper.minWidth(context, 129, widthFactor: 0.8),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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
          appBar: AppBar(),
          body: Center(
            child: SizedBox(
              width: UiHelper.minWidth(context, 300, widthFactor: 0.9),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _userNameController,
                    autofillHints: const [AutofillHints.namePrefix],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      labelText: "Name",
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _userEmailController,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      labelText: "E-mail ID",
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _urlController,
                    autofillHints: const [AutofillHints.url],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      labelText: "Remote URL",
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      labelText: "Auth Code",
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 48),
                  FilledButton(
                    onPressed: () {
                      bloc.add(GitCloneAttemptCloneEvent(
                        userName: _userNameController.text,
                        url: _urlController.text,
                        password: _passwordController.text,
                        userEmail: _userEmailController.text,
                      ));
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
      listener: (context, state) {
        if (state is GitCloneReturnState) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}

