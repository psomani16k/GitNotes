import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_notes/ui/GitPushPull/bloc/git_push_pull_bloc.dart';
import 'package:git_notes/ui/HomeScreens/HomeGit/model/home_git_model.dart';
import 'package:visibility_detector/visibility_detector.dart';

class GitPushPull extends StatefulWidget {
  const GitPushPull({super.key});

  @override
  State<GitPushPull> createState() => _GitPushPullState();
}

class _GitPushPullState extends State<GitPushPull> {
  bool repoExists = true;
  bool canCommit = false;
  bool canPush = false;
  bool processing = true;

  @override
  Widget build(BuildContext context) {
    GitPushPullBloc bloc = BlocProvider.of<GitPushPullBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Git Push/Pull"),
      ),
      body: BlocConsumer(
        bloc: bloc,
        listener: (context, state) {
          if (state is GitPushPullErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is GitPushPullInitial) {
            bloc.add(GitPushPullUpdateEvent());
          }

          if (state is GitPushPullUpdateActionsState) {
            repoExists = state.repoExists;
            canCommit = state.canCommit;
            canPush = state.canPush;
            processing = false;
          }

          if (state is GitPushPullProcessingState) {
            processing = true;
          }

          if (!repoExists) {
            return Center(
              child: Text(
                "Please clone a repository to continue.",
                style: TextTheme.of(context).labelLarge,
              ),
            );
          }

          return VisibilityDetector(
            key: const Key("git-push-pull"),
            onVisibilityChanged: (info) {
              if (info.visibleFraction > 0.01) {
                bloc.add(GitPushPullUpdateEvent());
              }
            },
            child: Column(
              children: [
                processing
                    ? const SizedBox(
                        height: 5,
                        child: LinearProgressIndicator(),
                      )
                    : const SizedBox(height: 5),
                const Flexible(child: _GitPushPullMessageRecievingBox()),
                _GitPushPullButtonBox(
                  canPush: canPush,
                  canCommit: canCommit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GitPushPullMessageRecievingBox extends StatelessWidget {
  const _GitPushPullMessageRecievingBox();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.secondary, width: 3),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.primaryContainer, // Glow color
              spreadRadius: 4, // Increases the size of the glow
              blurRadius: 20, // Softens the glow
              offset: const Offset(0, 0), // No shadow offset, centered glow
            ),
          ],
          borderRadius: BorderRadius.circular(36),
          color: Colors.black,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 36),
          ],
        ),
      ),
    );
  }
}

class _GitPushPullButtonBox extends StatelessWidget {
  _GitPushPullButtonBox({
    required this.canPush,
    required this.canCommit,
  });

  final bool canPush;
  final bool canCommit;
  final TextEditingController _commitMessageController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    GitPushPullBloc bloc = BlocProvider.of<GitPushPullBloc>(context);
    return SizedBox(
      height: 345,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: TextFormField(
              enabled: canCommit,
              controller: _commitMessageController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                labelText: "Commit Message",
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: canCommit
                ? () {
                    bloc.add(GitPushPullPerformCommitEvent(
                      message: _commitMessageController.text,
                    ));
                  }
                : null,
            child: SizedBox(
              width: 160,
              height: 60,
              child: Center(
                child: Text(
                  "Commit",
                  style: TextTheme.of(context).titleMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: canPush
                ? () {
                    bloc.add(GitPushPullPerformPushEvent());
                  }
                : null,
            child: SizedBox(
              width: 160,
              height: 60,
              child: Center(
                child: Text(
                  "Push",
                  style: TextTheme.of(context).titleMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(
            width: 120,
            child: Divider(
              thickness: 1,
              height: 1,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () {
              bloc.add(GitPushPullPerformPullEvent());
            },
            child: SizedBox(
              width: 160,
              height: 60,
              child: Center(
                child: Text(
                  "Pull",
                  style: TextTheme.of(context).titleMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
