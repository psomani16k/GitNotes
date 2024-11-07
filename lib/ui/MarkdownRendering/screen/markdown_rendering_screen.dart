import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_notes/ui/MarkdownRendering/bloc/markdown_rendering_bloc.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/inlines/all.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:protobuf/protobuf.dart';

class MarkdownRenderingScreen extends StatefulWidget {
  const MarkdownRenderingScreen({super.key, required this.file});
  final File file;

  @override
  State<MarkdownRenderingScreen> createState() =>
      _MarkdownRenderingScreenState();
}

class _MarkdownRenderingScreenState extends State<MarkdownRenderingScreen> {
  late String content;
  MarkdownRenderingBloc _bloc = MarkdownRenderingBloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc.add(MarkdownRenderingReadFileEvent(file: widget.file));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: BlocBuilder<MarkdownRenderingBloc, MarkdownRenderingState>(
        builder: (context, state) {
          if (state is MarkdownRenderingRenderDataState) {
            content = state.data;
            return Scaffold(
              body: markdownWidget(),
            );
          }
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  MarkdownWidget markdownWidget() {
    return MarkdownWidget(
      data: content,
      config: MarkdownConfig(configs: [
        ImgConfig(
          builder: (url, attributes) {
            Directory parent = widget.file.parent;
            String filePath = path.join(parent.path, url);
            File file = File(filePath);
            file = file.absolute;
            print(file.path);
            return Image.file(file);
          },
        )
      ]),
    );
  }
}
