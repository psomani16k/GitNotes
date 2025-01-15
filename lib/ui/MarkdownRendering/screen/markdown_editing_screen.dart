import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';
import 'dart:io';

class MarkdownEditingScreen extends StatefulWidget {
  const MarkdownEditingScreen({super.key, required this.file});
  final File file;

  @override
  State<MarkdownEditingScreen> createState() => _MarkdownEditingScreenState();
}

class _MarkdownEditingScreenState extends State<MarkdownEditingScreen> {
  late String fileRead;
  @override
  void initState() {
    super.initState();
    fileRead = widget.file.readAsStringSync();
    _markdownEditingController.text = fileRead;
  }

  final TextEditingController _markdownEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (fileRead == _markdownEditingController.text) {
          Navigator.pop(context);
        } else {
          await showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: SizedBox(
                  width: 170,
                  height: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        "Discard unsaved changes?",
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Discard"),
                          ),
                          const SizedBox(width: 20),
                          FilledButton(
                            onPressed: () {
                              String currentFileState =
                                  _markdownEditingController.text;
                              fileRead = currentFileState;
                              widget.file.writeAsStringSync(fileRead,
                                  mode: FileMode.write);
                              Navigator.pop(context);
                            },
                            child: const Text("Save"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
          Navigator.pop(context);
        }
      },
      child: Scaffold(
			
        appBar: AppBar(
          title: Text(widget.file.path.split("/").last),
          actions: [
            IconButton(
              onPressed: () {
                String currentFileState = _markdownEditingController.text;
                if (fileRead != currentFileState) {
                  fileRead = currentFileState;
                  widget.file.writeAsStringSync(fileRead, mode: FileMode.write);
                }
              },
              icon: const Icon(Icons.save),
            )
          ],
        ),
        body: MarkdownField(
          controller: _markdownEditingController,
          decoration: const InputDecoration(
            // labelText: 'Enter your text',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            // labelStyle: TextStyle(
            //   color: Colors.grey, // Color for the label text
            //   fontSize: 16, // Size for the label text
            // ),
            enabledBorder: InputBorder.none, // No border when not focused
            focusedBorder: InputBorder.none, // No border when focused
            contentPadding: EdgeInsets.symmetric(
                vertical: 12, horizontal: 6), // Adjust padding as needed
          ),
          style: TextStyle(
            fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
          ),
        ),
      ),
    );
  }
}
