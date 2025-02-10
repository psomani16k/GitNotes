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

  bool canPop = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        if (fileRead == _markdownEditingController.text) {
          print("same file, just pop");
          Navigator.pop(context);
        } else {
          print("not same file, show dialog");
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
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.file.path.split("/").last),
          // actions: [
          //   IconButton(
          //     onPressed: () {},
          //   )
          // ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            String currentFileState = _markdownEditingController.text;
            if (fileRead != currentFileState) {
              fileRead = currentFileState;
              widget.file.writeAsStringSync(fileRead, mode: FileMode.write);
            }
          },
          child: const Icon(Icons.save),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              MarkdownField(
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
                      horizontal: 8), // Adjust padding as needed
                ),
                style: TextStyle(
                  fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                ),
              ),
              const SizedBox(height: 120)
            ],
          ),
        ),
      ),
    );
  }
}
