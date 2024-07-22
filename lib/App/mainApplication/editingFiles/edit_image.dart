import 'dart:convert';
import 'dart:typed_data';

import 'package:daily/App/serverCommunication/client_post_info.dart';
import 'package:daily/widget_classes/display_image_content_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_editor_plus/image_editor_plus.dart';

class EditImage extends StatefulWidget {
  const EditImage({super.key});

  @override
  State<EditImage> createState() => _EditImageState();
}

class _EditImageState extends State<EditImage> with WidgetsBindingObserver {
  Future<String> encodeXFileToBase64(Uint8List fileBytes) async {
    // Compress the image using flutter_image_compress
    Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
      fileBytes,
      minHeight: 500, // Set minimum height (optional)
      minWidth: 500, // Set minimum width (optional)
      quality: 80, // Set compression quality (0-100)
    );

    // Encode the compressed bytes to base64 string
    String base64Image = base64Encode(compressedBytes);
    return base64Image;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) {
      if (mounted) {
        print("QUIT IN EDIT IMAGE");
        Navigator.pushReplacementNamed(context, '/');
        await cPI.exitApp(phoneNumber, username);
      }
    }
    //}
  }

  String title = "";
  String description = "";
  bool started = true;
  late XFile pickedFile;
  String username = "";
  String? phoneNumber;
  Uint8List? fileBytes;
  ClientPostInfo cPI = ClientPostInfo();
  @override
  Widget build(BuildContext context) {
    List postContentRecievedInfo =
        ModalRoute.of(context)!.settings.arguments as List;
    pickedFile = postContentRecievedInfo[1];
    phoneNumber = postContentRecievedInfo[0][0];
    username = postContentRecievedInfo[0][1];
    void trial() async {
      fileBytes = await pickedFile.readAsBytes();
      setState(() {});
    }

    if (started) {
      started = false;
      trial();
    }

    return SafeArea(
      child: Scaffold(
        body: fileBytes == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: <Widget>[
                  Text("TITLE:"),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        title = value;
                      });
                    },
                  ),
                  Text("DESCRIPTION:"),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        description = value;
                      });
                    },
                  ),
                  ElevatedButton(
                    child: const Text("ImageEditor"),
                    onPressed: () async {
                      if (mounted) {
                        Uint8List? editedImage = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageEditor(
                              image: fileBytes!,
                            ),
                          ),
                        );
                        // Replace with edited image
                        if (editedImage != null) {
                          fileBytes = editedImage;
                          setState(() {});
                        }
                      }
                    },
                  ),
                  ImageWidget(
                    recievedContent: {
                      "file": {
                        "Type": "IMAGE",
                        "File": base64Encode(fileBytes!)
                      },
                      "owner": username,
                      "contentId": "it will be given by the server",
                      "title": title,
                      "description": description,
                      "timeOfPost": DateTime.now().toString(),
                      "likes": 0,
                      "dislikes": 0,
                      "comments": [
                        {
                          "comment": "There are no comments",
                          "timeOfComment": DateTime.now().toString(),
                          "username": "!!!!!!!!",
                          "commentId": 0
                        }
                      ],
                      "noOfComments": 0,
                    },
                    location: "edit_image",
                    myData: [phoneNumber, username],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (mounted) {
                        String encodedImage =
                            await encodeXFileToBase64(fileBytes!);
                        await cPI.postContent(phoneNumber, username, title,
                            description, encodedImage, "IMAGE");

                        Navigator.pushReplacementNamed(
                          context,
                          '/viewContent',
                        );
                      }
                    },
                    child: const Text("PRESS ME TO POST THE IMAGE"),
                  ),
                  TextButton(
                    onPressed: () {
                      if (mounted) {
                        Navigator.pop(
                          context,
                        );
                      }
                    },
                    child: const Text("Return to view content"),
                  ),
                ],
              ),
      ),
    );
  }
}
