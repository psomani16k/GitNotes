import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_notes/helpers/git/git_repo_manager.dart';
import 'package:git_notes/messages/git_push_pull_messages.pbserver.dart';
import 'package:git_notes/ui/GitPushPull/bloc/git_push_pull_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rinf/rinf.dart';
import 'package:visibility_detector/visibility_detector.dart';

class GitPushPull extends StatelessWidget {
  const GitPushPull({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Git Push/Pull"),
      ),
      body: const _GitPushPull(),
    );
  }
}

class _GitPushPull extends StatefulWidget {
  const _GitPushPull();

  @override
  State<_GitPushPull> createState() => _GitPushPullState();
}

class _GitPushPullState extends State<_GitPushPull> {
  bool repoExists = true;
  bool canCommit = false;
  bool canPush = false;
  bool processing = true;
  TextEditingController commitMessageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    GitPushPullBloc bloc = BlocProvider.of<GitPushPullBloc>(context);

    return BlocConsumer<GitPushPullBloc, GitPushPullState>(
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
            mainAxisSize: MainAxisSize.max,
            children: [
              processing
                  ? const SizedBox(
                      height: 5,
                      child: LinearProgressIndicator(),
                    )
                  : const SizedBox(height: 5),
              Expanded(child: _GitPushPullMessageRecievingBox(context)),
              Center(
                child: _GitPushPullButtonBox(
                  commitMessageController: commitMessageController,
                  canPush: canPush,
                  canCommit: canCommit,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GitPushPullMessageRecievingBox extends StatefulWidget {
  const _GitPushPullMessageRecievingBox(this.parentContext);

  final BuildContext parentContext;

  @override
  State<_GitPushPullMessageRecievingBox> createState() =>
      _GitPushPullMessageRecievingBoxState();
}

class _GitPushPullMessageRecievingBoxState
    extends State<_GitPushPullMessageRecievingBox> {
  String repoId = GitRepoManager.getInstance().getRepoId()!;

  List<Widget> displayTextCache = [];

  Map<int, Widget> displayText = {};

  late StreamSubscription<RustSignal<GitPushPullMessage>> _subscription;

  @override
  void initState() {
    super.initState();
    displayText = {
      0: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: "gitnotes:",
              style: GoogleFonts.jetBrainsMonoTextTheme().labelSmall!.copyWith(
                    fontSize: 10,
                    color: Theme.of(widget.parentContext).colorScheme.tertiary,
                  )),
          TextSpan(
              text: "~/$repoId",
              style: GoogleFonts.jetBrainsMonoTextTheme().labelSmall!.copyWith(
                    fontSize: 10,
                    color: Theme.of(widget.parentContext).colorScheme.primary,
                  )),
          TextSpan(
              text: "\$",
              style: GoogleFonts.jetBrainsMonoTextTheme().labelSmall!.copyWith(
                    fontSize: 10,
                    color: Colors.grey.shade50,
                  )),
        ]),
      )
    };

    _subscription = GitPushPullMessage.rustSignalStream.listen(
      (event) {
        GitPushPullMessage message = event.message;
        if (message.predefinedMessage case PredefinedMsg.Commit) {
          displayText[0] = RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: "gitnotes:",
                  style: GoogleFonts.jetBrainsMonoTextTheme()
                      .labelSmall!
                      .copyWith(
                        fontSize: 10,
                        color:
                            Theme.of(widget.parentContext).colorScheme.tertiary,
                      )),
              TextSpan(
                  text: "~/$repoId",
                  style: GoogleFonts.jetBrainsMonoTextTheme()
                      .labelSmall!
                      .copyWith(
                        fontSize: 10,
                        color:
                            Theme.of(widget.parentContext).colorScheme.primary,
                      )),
              TextSpan(
                  text: "\$ git commit -m \"${message.msg}\"",
                  style:
                      GoogleFonts.jetBrainsMonoTextTheme().labelSmall!.copyWith(
                            fontSize: 10,
                            color: Colors.grey.shade50,
                          )),
            ]),
          );
        } else if (message.predefinedMessage case PredefinedMsg.Pull) {
          displayText[0] = RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: "gitnotes:",
                  style: GoogleFonts.jetBrainsMonoTextTheme()
                      .labelSmall!
                      .copyWith(
                        fontSize: 10,
                        color:
                            Theme.of(widget.parentContext).colorScheme.tertiary,
                      )),
              TextSpan(
                  text: "~/$repoId",
                  style: GoogleFonts.jetBrainsMonoTextTheme()
                      .labelSmall!
                      .copyWith(
                        fontSize: 10,
                        color:
                            Theme.of(widget.parentContext).colorScheme.primary,
                      )),
              TextSpan(
                  text: "\$ git pull",
                  style:
                      GoogleFonts.jetBrainsMonoTextTheme().labelSmall!.copyWith(
                            fontSize: 10,
                            color: Colors.grey.shade50,
                          )),
            ]),
          );
        } else if (message.predefinedMessage case PredefinedMsg.Push) {
          displayText[0] = RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: "gitnotes:",
                  style:
                      GoogleFonts.jetBrainsMonoTextTheme().labelSmall!.copyWith(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.tertiary,
                          )),
              TextSpan(
                  text: "~/$repoId",
                  style:
                      GoogleFonts.jetBrainsMonoTextTheme().labelSmall!.copyWith(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.primary,
                          )),
              TextSpan(
                  text: "\$ git push",
                  style:
                      GoogleFonts.jetBrainsMonoTextTheme().labelSmall!.copyWith(
                            fontSize: 10,
                            color: Colors.grey.shade50,
                          )),
            ]),
          );
        } else if (message.predefinedMessage case PredefinedMsg.None) {
          displayText[message.msgIndex] = Text(
            message.msg,
            style: GoogleFonts.jetBrainsMonoTextTheme().labelSmall!.copyWith(
                  fontSize: 10,
                  color: Colors.grey.shade50,
                ),
          );
        } else if (message.predefinedMessage case PredefinedMsg.End) {
          displayTextCache = processDisplayTextCache();
          displayText = {
            0: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "gitnotes:",
                    style: GoogleFonts.jetBrainsMonoTextTheme()
                        .labelSmall!
                        .copyWith(
                          fontSize: 10,
                          color: Theme.of(widget.parentContext)
                              .colorScheme
                              .tertiary,
                        )),
                TextSpan(
                    text: "~/$repoId",
                    style: GoogleFonts.jetBrainsMonoTextTheme()
                        .labelSmall!
                        .copyWith(
                          fontSize: 10,
                          color: Theme.of(widget.parentContext)
                              .colorScheme
                              .primary,
                        )),
                TextSpan(
                    text: "\$",
                    style: GoogleFonts.jetBrainsMonoTextTheme()
                        .labelSmall!
                        .copyWith(
                          fontSize: 10,
                          color: Colors.grey.shade50,
                        )),
              ]),
            )
          };
        }
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    print(displayText);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.secondary, width: 3),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primaryContainer,
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 0),
            ),
          ],
          borderRadius: BorderRadius.circular(36),
          color: Colors.black,
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.sizeOf(widget.parentContext).height - 500),
            child: SingleChildScrollView(
              reverse: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: processDisplayTextView(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> processDisplayTextCache() {
    List<Widget> output = [];
    List<int> keys = displayText.keys.toList();
    keys.sort();
    for (int i in keys) {
      output.add(displayText[i]!);
    }
    displayTextCache.addAll(output);
    return displayTextCache;
  }

  List<Widget> processDisplayTextView() {
    List<Widget> output = [];
    List<int> keys = displayText.keys.toList();
    keys.sort();
    for (int i in keys) {
      output.add(displayText[i]!);
    }
    output = [...displayTextCache, ...output];
    return output;
  }
}

class _GitPushPullButtonBox extends StatelessWidget {
  const _GitPushPullButtonBox(
      {required this.canPush,
      required this.canCommit,
      required this.commitMessageController});

  final bool canPush;
  final bool canCommit;
  final TextEditingController commitMessageController;

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
              controller: commitMessageController,
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
                      message: commitMessageController.text,
                    ));
                  }
                : null,
            child: SizedBox(
              width: 160,
              height: 60,
              child: Center(
                child: Text(
                  "Commit",
                  style: canCommit
                      ? TextTheme.of(context).titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary)
                      : TextTheme.of(context).titleMedium,
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
                  style: canPush
                      ? TextTheme.of(context).titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary)
                      : TextTheme.of(context).titleMedium,
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
