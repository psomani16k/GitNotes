import 'dart:io';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:path_provider/path_provider.dart';
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
        title: const Text('file'),
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
  Widget build(BuildContext context) {
    WebViewController viewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Theme.of(context).scaffoldBackgroundColor)
      ..addJavaScriptChannel("notelesscheckbox", onMessageReceived: (msg) {
        final parts = msg.message.split('-');

        final bool checked = parts[0] == 'true';

        final int id = int.parse(parts[1]);

        final index = checkboxPositions[id];

        mdData = mdData.substring(0, index) +
            (checked ? 'x' : ' ') +
            mdData.substring(index + 1);
        widget.mdFile.writeAsStringSync(mdData);
      });
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return WebViewWidget(controller: viewController..loadFile(htmlFile.path));
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
    String htmlData =
        md.markdownToHtml(mdData, extensionSet: md.ExtensionSet.gitHubFlavored);
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
      return 'input type="checkbox" onclick="notelesscheckbox.postMessage( this.checked + \'-$checkboxIndex\');"';
    });

    // Writing generated HTML to the temp file
    htmlFile = await htmlFile.writeAsString(htmlData);

    // Showing the output of the generated HTML
    setState(() {
      loading = false;
    });
  }
}
