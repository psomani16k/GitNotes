import 'package:flutter/material.dart';
import 'package:git_notes/helpers/git/git_repo_manager.dart';
import 'package:git_notes/helpers/ui_helper.dart';
import 'package:git_notes/messages/git_clone.pb.dart';

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
  _ScreenState _state = _ScreenState.entry;
  String data = "";
  void processClone() async {
    setState(() {
      _state = _ScreenState.cloning;
    });
    GitCloneCallback callback = await GitRepoManager.getInstance().clone(
        _userNameController.text,
        _userEmailController.text,
        _urlController.text,
        _passwordController.text);

    if (callback.status == GitCloneResult.Fail) {
      setState(() {
        data = callback.data;
        _state = _ScreenState.fail;
      });
    } else {
      setState(() {
        data = callback.data;
        _state = _ScreenState.success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading
    if (_state == _ScreenState.cloning) {
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
    if (_state == _ScreenState.fail) {
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
              Text(data),
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
    if (_state == _ScreenState.success) {
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
              Text(data),
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
      body: Center(
        child: SizedBox(
          width: UiHelper.minWidth(context, 300, widthFactor: 0.9),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _userNameController,
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
                  processClone();
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
  }
}

enum _ScreenState { entry, cloning, fail, success }
