import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HtmlRenderingScreen extends StatefulWidget {
  const HtmlRenderingScreen({super.key, required this.file});
  final File file;

  @override
  State<HtmlRenderingScreen> createState() => _HtmlRenderingScreenState();
}

class _HtmlRenderingScreenState extends State<HtmlRenderingScreen> {
  @override
  void initState() {
    super.initState();
  }

  WebViewController viewController = WebViewController();

  double _scale = 1;

  bool invertImage = false;

  void _applyScale() {
    final script = '''
      document.body.style.zoom = '$_scale';
    ''';
    viewController.runJavaScript(script);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.file.path.split("/").last),
          actions: <Widget>[
            IconButton(
              icon: Icon(invertImage
                  ? Icons.invert_colors_on_rounded
                  : Icons.invert_colors_off_rounded),
              onPressed: () {
                setState(() {
                  invertImage = !invertImage;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () {
                _scale += 0.1;
                _applyScale();
              },
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out),
              onPressed: () {
                _scale -= 0.1;
                if (_scale < 0.5) _scale = 0.5; // Set a minimum scale
                _applyScale();
              },
            ),
          ],
        ),
        body: ColorFiltered(
          colorFilter: invertImage
              ? const ColorFilter.matrix(<double>[
                  -1.0, 0.0, 0.0, 0.0, 255.0, //
                  0.0, -1.0, 0.0, 0.0, 255.0, //
                  0.0, 0.0, -1.0, 0.0, 255.0, //
                  0.0, 0.0, 0.0, 1.0, 0.0, //
                ])
              : const ColorFilter.matrix(<double>[
                  1.0, 0.0, 0.0, 0.0, 0.0, //
                  0.0, 1.0, 0.0, 0.0, 0.0, //
                  0.0, 0.0, 1.0, 0.0, 0.0, //
                  0.0, 0.0, 0.0, 1.0, 0.0, //
                ]),
          child: WebViewWidget(
            controller: viewController
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadFile(widget.file.path)
              ..runJavaScript('document.body.style.zoom = "1.0";'),
          ),
        ));
  }
}
