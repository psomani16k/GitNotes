import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:git_notes/ui/MarkdownRendering/MarkdownEditingScreen/screen/markdown_editing_screen.dart';
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
                CupertinoPageRoute(
                  builder: (context) =>
                      MarkdownEditingScreen(file: widget.file),
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
        imgCorrectedHtml = imgCorrectedHtml + correctedTag;
        return "";
      },
    );
    htmlData = imgCorrectedHtml;

    // cleaning this to enable math blocks
    htmlData = htmlData.replaceAll(r"<p>$$", "<div>\n%\$");
    htmlData = htmlData.replaceAll(r"$$</p>", "\$%\n</div>");

    // cleaning mermaid tag
    htmlData = htmlData.replaceAllMapped(
      RegExp(
        r'<pre><code class="language-mermaid">(?:(?!<pre>)[\s\S])*?</code></pre>',
      ),
      (match) {
        String matchString = htmlData.substring(match.start, match.end);
        matchString = matchString.substring(36, matchString.length - 13);
        return '''
<pre class="mermaid">
$matchString
</pre>
				''';
      },
    );
// <pre><code class="language-mermaid">flowchart TD

    // Pretifying the HTML
    htmlData = prettifyHtml(htmlData, context);

    // Writing generated HTML to the temp file
    htmlFile = await htmlFile.writeAsString(htmlData);

    // Showing the output of the generated HTML
    setState(() {
      loading = false;
    });
  }

  String prettifyHtml(
    String html,
    BuildContext context,
  ) {
    // List<String> split = html.split("\n");
    // split.forEach((element) {
    //   print(element);
    // });
    // theme colors
    String surface = Theme.of(context).colorScheme.surface.toHexString();
    String onSurface = Theme.of(context).colorScheme.onSurface.toHexString();
    String surfaceTint =
        Theme.of(context).colorScheme.surfaceTint.toHexString();

    String divider = Theme.of(context).dividerColor.toHexString();

    String primary = Theme.of(context).colorScheme.primary.toHexString();
    String onPrimary = Theme.of(context).colorScheme.onPrimary.toHexString();

    String secondary = Theme.of(context).colorScheme.secondary.toHexString();
    String onSecondary =
        Theme.of(context).colorScheme.onSecondary.toHexString();

    String tertiary = Theme.of(context).colorScheme.tertiary.toHexString();
    String onTertiary = Theme.of(context).colorScheme.onTertiary.toHexString();

    String primaryContainer =
        Theme.of(context).colorScheme.primaryContainer.toHexString();
    String onPrimaryContainer =
        Theme.of(context).colorScheme.onPrimaryContainer.toHexString();

    String secondaryContainer =
        Theme.of(context).colorScheme.secondaryContainer.toHexString();
    String onSecondaryContainer =
        Theme.of(context).colorScheme.onSecondaryContainer.toHexString();

    String tertiaryContainer =
        Theme.of(context).colorScheme.tertiaryContainer.toHexString();
    String onTertiaryContainer =
        Theme.of(context).colorScheme.onTertiaryContainer.toHexString();

    String textColor = TextTheme.of(context).bodySmall!.color!.toHexString();

    // css
    String css = """
:root {
  --surface: $surface;
  --on-surface: $onSurface;
	--surface-tint: $surfaceTint;

	--divider-color: $divider;

  --primary: $primary;
  --on-primary: $onPrimary;

  --secondary: $secondary;
  --on-secondary: $onSecondary;

  --tertiary: $tertiary;
  --on-tertiary: $onTertiary;

  --primary-container: $primaryContainer;
  --on-primary-container: $onPrimaryContainer;

  --secondary-container: $secondaryContainer;
  --on-secondary-container: $onSecondaryContainer;

  --tertiary-container: $tertiaryContainer;
  --on-tertiary-container: $onTertiaryContainer;

  --text-color: $textColor;
}

/*  HEADINGS  */

h1, h2, h3, h4, h5, h6 {
    font-weight: 600;
    color: var(--text-color); 
		margin-top: 0;
    margin-bottom: 0.5em;
}

/* Specific Heading Sizes */
h1 {
    font-size: 32px; /* 36px */
    line-height: 1.1;
}

h2 {
    font-size: 28px; /* 28px */
    line-height: 1.2;
}

h3 {
    font-size: 24px; /* 24px */
    line-height: 1.25;
}

h4 {
    font-size: 20px; /* 20px */
    line-height: 1.3;
}

h5 {
    font-size: 18px; /* 18px */
    line-height: 1.35;
}

h6 {
    font-size: 16px;
    line-height: 1.4;
}

h1, h2, h3 {
    border-bottom: 1px solid var(--divider-color);
    padding-bottom: 0.3em;
}

h1, h2, h3, h4, h5, h6 {
    margin-top: 1.2em;
    margin-bottom: 1em;
}



body {
    font-size: 14px;
    line-height: 1.5;
    color: var(--on-surface); 
    margin: 0;
    padding: 20px;
}

/* Centered container like GitHub */
.container {
    max-width: 900px;
    margin: 0 auto;
    background: white;
    padding: 20px;
    border: 1px solid #d0d7de;
    border-radius: 6px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}


/* LINKS */

a {
    color: #0969da;
    text-decoration: none;
}

a:hover {
    text-decoration: underline;
}


/* CODE BLOCKS */

code {
    font-family: monospace;
    background-color: #000000;
    padding: 2px 4px;
    border-radius: 4px;
}


/* LISTS */

ul {
    padding-left: 20px;
}


/*  HORIZONTAL RULE */

hr {
    border: 0;
    height: 1px;
    background: var(--divider-color);
    margin: 20px 0;
}


/*  TABLES  */

.table-container {
    width: 100%;
    overflow-x: auto;
}

table {
    border-collapse: collapse;
    background-color: var(--secondary-container);
		color: var(--on-secondary-container);
}

th, td {
    border: 1px solid var(--divider-color);
    padding: 8px;
    text-align: left;
}

th {
    background-color: var(--tertiary-container);
    font-weight: 600;
		color: var(--on-tertiary-container)
}

tr:nth-child(even) {
    background-color: var(--tertiary-container);
		color: var(--on-tertiary-container)
}


""";

    // html
    html = '''
<!DOCTYPE html>
<html>
<head>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- KaTeX CSS -->

  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">

  <!-- Optional: Auto-render extension -->

  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"></script>

	<style>
		$css
	</style> 

</head>
<body>
		$html
<div class="spacer" style="height: 150px;"></div>


<script>
    document.addEventListener("DOMContentLoaded", function () {
        renderMathInElement(document.body, {
            delimiters: [
                { left: "\$", right: "\$", display: false },
								{ left: "%\$", right: "\$%", display: true }
            ]
        });
    });
</script>

<script type="module">
  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
	
  document.addEventListener("DOMContentLoaded", function () {
    mermaid.initialize({
      theme: 'base',
      themeVariables: {
        primaryColor: '$primaryContainer',
        primaryTextColor: '$onPrimaryContainer',
        primaryBorderColor: '$divider',
        lineColor: '$divider',
        nodeTextColor: '$textColor',
        secondaryColor: '$secondaryContainer',
        tertiaryColor: '$tertiaryContainer',
        edgeLabelBackground: '$surfaceTint'
      }
    });

    // Force Mermaid to render all diagrams
    mermaid.init();
  });

</script>

</body>
		''';
    return html;
  }
}

extension ColorToHexString on Color {
  String toHexString() {
    return "#${value.toRadixString(16).padLeft(8, '0').substring(2)}";
  }
}
