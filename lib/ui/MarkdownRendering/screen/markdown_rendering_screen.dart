import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:git_notes/ui/MarkdownRendering/bloc/markdown_rendering_bloc.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/inlines/all.dart';
import 'package:markdown_widget/widget/markdown.dart';

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
              body: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.sizeOf(context).width * 0.03),
                child: markdownWidget(),
              ),
            );
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  MarkdownWidget markdownWidget() {
    return MarkdownWidget(
      data: content,
      selectable: true,
      config: MarkdownConfig(configs: [
        CodeConfig(style: GoogleFonts.jetBrainsMono()),
        ImgConfig(
          builder: (url, attributes) {
            Directory parent = widget.file.parent;
            String filePath = path.join(parent.path, url);
            File file = File(filePath);
            file = file.absolute;
            return GestureDetector(
                onTap: () async {
                  await OpenFile.open(file.path);
                },
                child: Image.file(file));
          },
        )
      ]),
    );
  }
}
