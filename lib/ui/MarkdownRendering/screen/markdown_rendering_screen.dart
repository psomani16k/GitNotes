import 'dart:io';
import 'package:flutter/material.dart';
import 'package:git_notes/ui/MarkdownRendering/screen/markdown_editing_screen.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
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
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                PageTransition(
                  child: MarkdownEditingScreen(file: widget.file),
                  childCurrent: widget,
                  type: PageTransitionType.rightToLeftWithFade,
                  curve: Curves.easeInOut,
                  reverseDuration: Durations.long1,
                  duration: Durations.long1,
                ),
              );
              setState(() {});
            },
            icon: const Icon(Icons.edit_note),
          )
        ],
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
      ..addJavaScriptChannel("GitNotesCheckBox", onMessageReceived: (msg) {
        final parts = msg.message.split('-');
        final bool checked = parts[0] == 'true';
        final int id = int.parse(parts[1]);
        final index = checkboxPositions[id];
        mdData = mdData.substring(0, index) +
            (checked ? 'x' : ' ') +
            mdData.substring(index + 1);
        widget.mdFile.writeAsStringSync(mdData);
      })
      ..addJavaScriptChannel(
        "GitNotesLink",
        onMessageReceived: (msg) {
          if (msg.message.startsWith("./") || msg.message.startsWith("../")) {
            File file = File("${widget.mdFile.parent.path}/${msg.message}");
            Navigator.of(context).push(
              PageTransition(
                child: MarkdownRenderingScreen(file: file),
                childCurrent: widget,
                type: PageTransitionType.rightToLeftWithFade,
                curve: Curves.easeInOut,
                reverseDuration: Durations.long1,
                duration: Durations.long1,
              ),
            );
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

    // Indexing all the checkboxes
    for (final match in RegExp(r'- \[(x| )\]').allMatches(mdData)) {
      checkboxPositions.add(match.start + 3);
    }

    // Creating a temperory cache directory for generated html
    Directory cache = await getApplicationDocumentsDirectory();
    htmlFile = File("${cache.path}/temp.html");
    await htmlFile.create(recursive: true);

    // Generating HTML preview
    String htmlData = md.markdownToHtml(
      mdData,
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );

    // Making linking files work
    htmlData = htmlData.replaceAll("<a href=",
        '<a onclick=" event.preventDefault(); GitNotesLink.postMessage(this.getAttribute(\'href\'));" href=');

    const staticPreviewDir =
        'file:///android_asset/flutter_assets/assets/preview';
    ThemeData theme = widget.theme;
    String backgroundColor = theme.scaffoldBackgroundColor.value
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2);
    String textColor = theme.textTheme.bodySmall!.color!.value
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2);
    String accentColor = theme.colorScheme.primary.value
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2);

    // Pretifying the HTML
    htmlData = '''
<!DOCTYPE html>
<html>
<head>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
  body {
    background-color: #$backgroundColor;
    color: #$textColor;
  }
  a {
    color: #$accentColor;
  }
  img {
    filter: grayscale(20%);
  }
  </style>
  
	<link href="$staticPreviewDir/prism.css" rel="stylesheet" />

  <link rel="stylesheet" href="$staticPreviewDir/katex.min.css">

  <script defer src="$staticPreviewDir/katex.min.js"></script>

  <script defer src="$staticPreviewDir/mhchem.min.js"></script>

  <script src="$staticPreviewDir/asciimath2tex.umd.js" ></script>



    <!-- KaTeX auto-render extension -->
    <script defer src="$staticPreviewDir/katex.auto-render.min.js"
        onload="const parser = new AsciiMathParser();renderMathInElement(document.body, 
        {delimiters:
        [
          {left: '\$\$', right: '\$\$', display: true},
          {left: '\$', right: '\$', display: false},
        ],
        preProcess: (math)=>{
          return math.trim();
        }
        });
		renderMathInElement(document.body, 
        {delimiters:
        [
          {left: '&&', right: '&&', display: true},
          {left: '&', right: '&', display: false},
        ],
        preProcess: (math)=>{
          return parser.parse(math.trim());
        }
        });
		"></script>

	<style>
		table {
  		border-collapse: collapse;
		}

		table, th, td {
  		border: 1px solid ${theme.brightness == Brightness.light ? 'lightgrey' : 'grey'};
		}

		th, td {
  		padding: 8px;
		}

		tr:nth-child(even) {background-color: ${theme.brightness == Brightness.light ? '#f2f2f2' : '#404040'};}

		pre {
  		max-width: 100%;
  		overflow-x: scroll;
		}

		blockquote{
  		padding: 0em 0em 0em .6em;
  		margin-left: .1em;
  		border-left: 0.3em solid ${theme.brightness == Brightness.light ? 'lightgrey' : 'grey'};
		}


	</style>
</head>
<body>
		$htmlData
</body>

<script src="$staticPreviewDir/mermaid.min.js"></script>

<script>mermaid.initialize({startOnLoad:true}, ".language-mermaid");</script>

<script src="$staticPreviewDir/prism.js"></script>

<script>
  document.querySelectorAll(".language-mermaid").forEach(function(entry) {
      entry.className="mermaid"
	});
  mermaid.initialize({startOnLoad:true}, ".language-mermaid");
</script>
		''';

    // Setting checkbox callbacks
    int checkboxIndex = -1;
    htmlData = htmlData.replaceAllMapped('input type="checkbox"', (match) {
      checkboxIndex++;
      return 'input type="checkbox" onclick="GitNotesCheckBox.postMessage( this.checked + \'-$checkboxIndex\');"';
    });

    // Making images work
    htmlData = htmlData.replaceAll("<img ", '<img width="100%" ');

    String imgCorrectedHtml = "";
    htmlData.splitMapJoin(
      RegExp(r'<img width="100%" src="([^"]*)"(.*)/>'),
      onNonMatch: (p0) {
        imgCorrectedHtml = "$imgCorrectedHtml\n$p0";
        return "";
      },
      onMatch: (p0) {
        RegExpMatch altMatch = RegExp(r'alt="([^"]*)"').firstMatch(p0[0]!)!;
        String alt = p0[0]!.substring(altMatch.start + 5, altMatch.end - 1);
        RegExpMatch srcMatch = RegExp(r'src="([^"]*)"').firstMatch(p0[0]!)!;
        String src = p0[0]!.substring(srcMatch.start + 5, srcMatch.end - 1);
        if (src.startsWith("./") || src.startsWith("../")) {
          src = "file://${widget.mdFile.parent.path}/$src";
        }
        String correctedTag = '<img width="100%" src="$src" alt="$alt" />';
        print(correctedTag);
        imgCorrectedHtml = imgCorrectedHtml + correctedTag;
        return "";
      },
    );
    htmlData = imgCorrectedHtml;

    // Writing generated HTML to the temp file
    htmlFile = await htmlFile.writeAsString(htmlData);

    // Showing the output of the generated HTML
    setState(() {
      loading = false;
    });
  }
}
