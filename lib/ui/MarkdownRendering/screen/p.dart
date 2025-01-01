import 'dart:io';

import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as markd;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage(
      {super.key, required this.theme, required this.textContent});
  final ThemeData theme;
  final String textContent;

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  // BuildContext context;

  late String currentTextContent;

  @override
  void initState() {
    _processContent();
    super.initState();
  }

  List<int> checkboxPositions = [];

  late File previewFile;

  void _processContent() async {
    //this.context = context;

    ThemeData theme = widget.theme;
    Directory directory = await getApplicationCacheDirectory();
    final previewDir = Directory('${directory.path}/preview');
    const staticPreviewDir =
        'file:///android_asset/flutter_assets/assets/preview';
    previewFile = File('${previewDir.path}/index.html');
    previewFile.createSync(recursive: true);
    currentTextContent = widget.textContent;
    for (final match in RegExp(r'- \[(x| )\]').allMatches(currentTextContent)) {
      // print(match);
      checkboxPositions.add(match.start + 1);
    }
    String content = widget.textContent;
    // Wiki-Style note links like [[Note]]
    content = content.replaceAllMapped(RegExp(r'\[\[[^\]]+\]\]'), (match) {
      var str = match.input.substring(match.start, match.end);
      String title = str.substring(2).split(']').first;
      return '[$title](@note/$title${title.endsWith('.md') ? '' : '.md'})';
    });
    content =
        content.replaceAllMapped(RegExp(r'(?<=\]\(@note\/).*(?=\))'), (match) {
      return content.substring(match.start, match.end).replaceAll(' ', '%20');
    });
    content = content.replaceAll(RegExp(r'\\\\'), '\\\\\\\\');
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
    String generatedPreview = '''

		${'''<!DOCTYPE html>
<html>
<head>
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
                      ''' + markd.markdownToHtml(
              content,
              extensionSet: markd.ExtensionSet.gitHubWeb,
              /* blockSyntaxes: [FencedCodeBlockSyntax()], */
            )}<script src="$staticPreviewDir/mermaid.min.js"></script>
<script>mermaid.initialize({startOnLoad:true}, ".language-mermaid");</script>


<script src="$staticPreviewDir/prism.js"></script>

      
  <script>
  document.querySelectorAll(".language-mermaid").forEach(function(entry) {
      entry.className="mermaid"
});
  mermaid.initialize({startOnLoad:true}, ".language-mermaid");
  </script>

<script>
 window.addEventListener('load', function () {
        flutternotable.postMessage('');
});
</script>

  </body>
  </html>''';
    generatedPreview =
        generatedPreview.replaceAll('<img ', '<img width="100%" ');
    int checkboxIndex = -1;
    generatedPreview = generatedPreview.replaceAllMapped(
      'disabled="disabled" class="todo" type="checkbox"', (match) {
      checkboxIndex++;
      return 'class="todo" type="checkbox" onclick="notelesscheckbox.postMessage( this.checked + \'-$checkboxIndex\');"';
    });
    await previewFile.writeAsString(generatedPreview);
    setState(() {
      _processingDone = true;
      _pageLoaded = true;
    });
    print(_processingDone);
  }

  bool _processingDone = false;

  bool _pageLoaded = false;

  @override
  Widget build(BuildContext context) {
    // print('BUILD');

    // WebViewController viewController = ;

    return StatefulBuilder(
      builder: (context, setState) {
        return !_processingDone
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: <Widget>[
                  WebViewWidget(
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..loadRequest(Uri.file(previewFile.path))
                      ..enableZoom(true)
                      ..addJavaScriptChannel(
                        "flutternotable",
                        onMessageReceived: (_) async {
                          setState(() {
                            _pageLoaded = true;
                          });
                        },
                      )
                      ..addJavaScriptChannel("notelesscheckbox",
                          onMessageReceived: (msg) {
                        final parts = msg.message.split('-');

                        final bool checked = parts[0] == 'true';

                        final int id = int.parse(parts[1]);

                        final index = checkboxPositions[id];

                        currentTextContent =
                            currentTextContent.substring(0, index) +
                                (checked ? 'x' : ' ') +
                                currentTextContent.substring(index + 1);
                      })
                      ..setNavigationDelegate(NavigationDelegate(
                        onNavigationRequest: (request) {
                          if (request.url.startsWith('file://')) {
                            String? link = Uri.decodeFull(
                                RegExp(r'@.*').stringMatch(request.url)!);
                            String type =
                                RegExp(r'(?<=@).*(?=/)').stringMatch(link)!;
                            String data =
                                RegExp(r'(?<=/).*').stringMatch(link)!;
                            switch (type) {
                              case 'note':
                                _navigateToNote(data);
                                break;
                              case 'tag':
                                _navigateToTag(data);
                                break;
                              case 'search':
                                _navigateToSearch(data);
                                break;
                              case 'attachment':
                                break;
                            }
                          } else {
                            launchUrl(
                              Uri(scheme: request.url),
                            );
                          }
                          return NavigationDecision.prevent;
                        },
                      )),
                  ),
                  if (!_pageLoaded)
                    Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    ),
                ],
              );
      },
    );
  }

  void _navigateToNote(String title) async {}

  void _navigateToTag(String tag) async {}

  void _navigateToSearch(String search) async {}
}
