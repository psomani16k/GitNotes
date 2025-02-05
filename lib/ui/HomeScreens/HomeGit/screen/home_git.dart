import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:git_notes/ui/HomeScreens/HomeGit/bloc/home_git_bloc.dart';
import 'package:git_notes/ui/HomeScreens/HomeGit/model/home_git_model.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeGit extends StatefulWidget {
  const HomeGit({super.key});
  @override
  State<HomeGit> createState() => _HomeGitState();
}

class _HomeGitState extends State<HomeGit> {
  List<FileStatusData>? staged = [];
  List<FileStatusData>? changed = [];
  bool stageLoading = false;
  bool statusLoading = true;

  @override
  Widget build(BuildContext context) {
    HomeGitBloc bloc = BlocProvider.of<HomeGitBloc>(context);
    return BlocConsumer<HomeGitBloc, HomeGitState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is HomeGitSoftErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is HomeGitInitial) {
          bloc.add(HomeGitInitialEvent());
        }
        if (state is HomeGitInitialState) {
          staged = state.staged;
          changed = state.changed;
          stageLoading = false;
          statusLoading = false;
        }

        if (state is HomeGitAddRemoveProcessingState) {
          stageLoading = true;
        }

        if (state is HomeGitRepoChangeProcessingState) {
          statusLoading = true;
        }

        if (state is HomeGitRepoUpdateState) {
          staged = state.staged;
          changed = state.changed;
          stageLoading = false;
          statusLoading = false;
        }

        if (state is HomeGitUpdateViewState) {
          staged = state.staged;
          changed = state.changed;
          stageLoading = false;
          statusLoading = false;
        }

        if (state is HomeGitHardErrorState) {
          return Center(
            child: Text(
              state.message,
              style: TextTheme.of(context).labelLarge,
            ),
          );
        }

        if (changed == null || staged == null) {
          return Center(
            child: Text(
              "Please clone a repository to continue.",
              style: TextTheme.of(context).labelLarge,
            ),
          );
        }

        return VisibilityDetector(
          key: const Key("home-git"),
          onVisibilityChanged: (info) {
            if (info.visibleFraction > 0.01) {
              bloc.add(HomeGitUpdateViewEvent());
            }
          },
          child: statusLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    stageLoading
                        ? const SizedBox(
                            height: 4,
                            child: LinearProgressIndicator(),
                          )
                        : const SizedBox(height: 4),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          _HomeGitStagedFiles(statusData: staged!),
                          _HomeGitChangedFiles(statusData: changed!),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _HomeGitStagedFiles extends StatelessWidget {
  final List<FileStatusData> statusData;
  const _HomeGitStagedFiles({required this.statusData});

  @override
  Widget build(BuildContext context) {
    Widget statusEmptyMessage = statusData.isEmpty
        ? SizedBox(
            height: 75,
            width: MediaQuery.sizeOf(context).width,
            child: Center(
              child: Text(
                "No files staged for commit",
                style: TextTheme.of(context).titleSmall,
              ),
            ),
          )
        : const SizedBox(height: 0);
    HomeGitBloc homeGitBloc = BlocProvider.of<HomeGitBloc>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // space for the linear indicator
        const SizedBox(height: 4),
        // staged inticator
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Center(
              child: Text(
                "Staged",
                style: TextTheme.of(context).titleMedium,
              ),
            ),
          ),
        ),
        statusEmptyMessage,
        ...statusData.map<Widget>((status) {
          return SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: 75,
            child: Column(
              children: [
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withAlpha(120),
                        ),
                        child: Center(
                          child: Text(
                            status.getChangeChar(),
                            style: TextTheme.of(context).titleMedium!.copyWith(
                                color: status.getChangedCharColor(),
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width - 132,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status.getFileName(),
                            overflow: TextOverflow.ellipsis,
                            style: TextTheme.of(context).titleSmall,
                          ),
                          Text(
                            status.relativeFilePath,
                            overflow: TextOverflow.visible,
                            style: TextTheme.of(context).labelSmall!.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(120),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: IconButton.filled(
                        onPressed: () {
                          // git un-stage
                          homeGitBloc.add(HomeGitUnstageFileEvent(
                              relativeFilePath: status.relativeFilePath));
                        },
                        icon: const Icon(Icons.remove),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 56,
                  endIndent: 24,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _HomeGitChangedFiles extends StatelessWidget {
  final List<FileStatusData> statusData;
  const _HomeGitChangedFiles({required this.statusData});

  @override
  Widget build(BuildContext context) {
    HomeGitBloc homeGitBloc = BlocProvider.of<HomeGitBloc>(context);
    Widget statusEmptyMessage = statusData.isEmpty
        ? SizedBox(
            height: 75,
            width: MediaQuery.sizeOf(context).width,
            child: Center(
              child: Text(
                "No files to be staged",
                style: TextTheme.of(context).titleSmall,
              ),
            ),
          )
        : const SizedBox(height: 0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // space for the linear indicator
        const SizedBox(height: 4),
        // staged inticator
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Center(
              child: Text(
                "Changed",
                style: TextTheme.of(context).titleMedium,
              ),
            ),
          ),
        ),
        statusEmptyMessage,
        ...statusData.map<Widget>((status) {
          return SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: 75,
            child: Column(
              children: [
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withAlpha(120),
                        ),
                        child: Center(
                          child: Text(
                            status.getChangeChar(),
                            style: TextTheme.of(context).titleMedium!.copyWith(
                                color: status.getChangedCharColor(),
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width - 180,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status.getFileName(),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            overflow: TextOverflow.visible,
                            status.relativeFilePath,
                            style: TextTheme.of(context).labelSmall!.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(120),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton.filled(
                      onPressed: () {
                        // git restore
                        homeGitBloc.add(HomeGitRestoreFileEvent(
                            relativeFilePath: status.relativeFilePath));
                      },
                      icon: const Icon(
                          MaterialCommunityIcons.file_restore_outline),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: IconButton.filled(
                        onPressed: () {
                          // git add
                          homeGitBloc.add(HomeGitStageFileEvent(
                              relativeFilePath: status.relativeFilePath));
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 56,
                  endIndent: 24,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
