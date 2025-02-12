import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:git_notes/helpers/git/git_repo_manager.dart';
import 'package:git_notes/messages/markdown.pbserver.dart';
import 'package:git_notes/ui/MarkdownRendering/MarkdownEditingScreen/screen/markdown_editing_screen.dart';
import 'package:git_notes/ui/MarkdownRendering/MarkdownRenderingScreen/helper/markdown_rendering_helper.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:path_provider/path_provider.dart';
import 'package:rinf/rinf.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MarkdownRenderingScreen extends StatefulWidget {
  const MarkdownRenderingScreen({super.key, required this.file});
  final File file;

  @override
  State<MarkdownRenderingScreen> createState() =>
      _MarkdownRenderingScreenState();
}

class _MarkdownRenderingScreenState extends State<MarkdownRenderingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.path.split("/").last),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => MarkdownEditingScreen(file: widget.file),
            ),
          );
          setState(() {});
        },
        child: const Icon(Icons.edit_note),
      ),
      body: MarkdownPreview(
        theme: Theme.of(context),
        mdFile: widget.file,
      ),
    );
  }
}

class MarkdownPreview extends StatefulWidget {
  const MarkdownPreview({super.key, required this.theme, required this.mdFile});
  final File mdFile;
  final ThemeData theme;

  @override
  State<MarkdownPreview> createState() => _MarkdownPreviewState();
}

class _MarkdownPreviewState extends State<MarkdownPreview> {
  bool loading = true;

  late File htmlFile;

  late String mdData;

  List<int> checkboxPositions = [];

  MarkdownRenderingHelper _renderingHelper = MarkdownRenderingHelper();

  @override
  void initState() {
    super.initState();
    processMarkdown();
  }

  @override
  void didUpdateWidget(covariant MarkdownPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    processMarkdown();
  }

  @override
  Widget build(BuildContext context) {
    WebViewController viewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Theme.of(context).scaffoldBackgroundColor)
      // javascript channel to manipulate checkboxes
      ..addJavaScriptChannel("GitNotesCheckBox", onMessageReceived: (msg) {
        int column = int.parse(msg.message.split(":").first);
        List<String> mdDataLineWise = mdData.split("\n");
        String taskString = mdDataLineWise[column - 1];
        int checkboxIndex = taskString.indexOf("[") + 1;
        if (taskString[checkboxIndex] == " ") {
          taskString =
              taskString.replaceRange(checkboxIndex, checkboxIndex + 1, "x");
        } else {
          taskString =
              taskString.replaceRange(checkboxIndex, checkboxIndex + 1, " ");
        }
        mdDataLineWise[column - 1] = taskString;
        mdData = mdDataLineWise.join("\n");
        widget.mdFile.writeAsStringSync(mdData);
      })
      // javascript channel to open links
      ..addJavaScriptChannel(
        "GitNotesLink",
        onMessageReceived: (msg) {
          String message = msg.message;
          // for relative links
          File file = File("${widget.mdFile.parent.path}/$message");
          if (file.existsSync()) {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => MarkdownRenderingScreen(file: file),
              ),
            );
            return;
          }
          file = File(
              "${GitRepoManager.getInstance().repoDirectory()!.path}/$message");
          if (file.existsSync()) {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => MarkdownRenderingScreen(file: file),
              ),
            );
            return;
          } else {
            launchUrlString(msg.message);
          }
        },
      );
    if (loading) {
      return Center(
        child: PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, result) {
              Navigator.of(context).pop();
            },
            child: const CircularProgressIndicator()),
      );
    } else {
      return WebViewWidget(
        controller: viewController..loadFile(htmlFile.path),
      );
    }
  }

  void processMarkdown() async {
    mdData = await widget.mdFile.readAsString();

    // Creating a temperory cache directory for generated html
    Directory cache = await getApplicationDocumentsDirectory();
    htmlFile = File("${cache.path}/temp.html");
    await htmlFile.create(recursive: true);

    // Generating HTML preview
    // TODO: replace this with rust implementation
    // String htmlDataDart = md.markdownToHtml(
    //   mdData,
    //   extensionSet: md.ExtensionSet.gitHubFlavored,
    // );
    //
    // for (String i in htmlDataDart.split("\n")) {
    //   print("dart --->$i");
    // }

    ProcessMarkdown(markdownData: mdData).sendSignalToRust();

    Stream<RustSignal<ProcessMarkdownCallback>> rustSignal =
        ProcessMarkdownCallback.rustSignalStream;
    RustSignal<ProcessMarkdownCallback> callback = await rustSignal.first;
    String htmlData = callback.message.htmlData;

    // Making images work
    String imgCorrectedHtml = "";
    htmlData.splitMapJoin(
      RegExp(r'<img[^>]*>'),
      onNonMatch: (p0) {
        imgCorrectedHtml = "$imgCorrectedHtml\n$p0";
        return "";
      },
      onMatch: (p0) {
        RegExpMatch altMatch = RegExp(r'alt="([^"]*)"').firstMatch(p0[0]!)!;
        String alt = p0[0]!.substring(altMatch.start + 5, altMatch.end - 1);
        RegExpMatch srcMatch = RegExp(r'src="([^"]*)"').firstMatch(p0[0]!)!;
        String src = p0[0]!.substring(srcMatch.start + 5, srcMatch.end - 1);

        String fileRelativePath = "${widget.mdFile.parent.path}/$src";
        File fileRelative = File(fileRelativePath);

        String fileAbsolutePath =
            "${GitRepoManager.getInstance().repoDirectory()!.path}/$src";
        File fileAbsolute = File(fileAbsolutePath);

        if (fileRelative.existsSync()) {
          src = "file://$fileRelativePath";
        } else if (fileAbsolute.existsSync()) {
          src = "file://$fileAbsolutePath";
        }
        String correctedTag = '<img width="100%" src="$src" alt="$alt" />';
        imgCorrectedHtml = imgCorrectedHtml + correctedTag;
        return "";
      },
    );
    htmlData = imgCorrectedHtml;

    // cleaning mermaid tag
    htmlData = htmlData.replaceAllMapped(
      RegExp(
        r'<pre><code[^>]*class="language-mermaid">(?:(?!<pre>)[\s\S])*?</code></pre>',
      ),
      (match) {
        String matchString = htmlData.substring(match.start, match.end);
        int index = matchString.indexOf("language-mermaid");
        matchString = matchString.substring(index + 18, matchString.length - 13);
        String ret = """
<pre class="mermaid">
$matchString
</pre>
				""";
        return ret;
      },
    );

    // Pretifying the HTML
    htmlData = _renderingHelper.prettifyHtml(htmlData, context);

    // Writing generated HTML to the temp file
    htmlFile = await htmlFile.writeAsString(htmlData);

    // Showing the output of the generated HTML
    setState(() {
      loading = false;
    });
  }
}
