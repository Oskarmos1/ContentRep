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

class _EditImageState extends State<EditImage> {
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

  bool started = true;
  late XFile pickedFile;
  String? phoneNumber;
  String? username;
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
                  ElevatedButton(
                    child: const Text("ImageEditor"),
                    onPressed: () async {
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
                    },
                  ),
                  ImageWidget(
                    recievedContent: {
                      "file": {
                        "Type": "IMAGE",
                        "File": base64Encode(fileBytes!)
                      },
                      "owner": username,
                      "timeOfPost": DateTime.now().toString(),
                      "likes": 0,
                      "dislikes": 0,
                      "noOfComments": 0
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      String encodedImage =
                          await encodeXFileToBase64(fileBytes!);
                      /*
                      await http.post(Uri.parse("http://192.168.0.19:400"),
                          body: jsonEncode({
                            "PhoneNumber": phoneNumber,
                            "Username": username,
                            "Location": "test",
                            "Post": {"File": encodedImage, "Type": "IMAGE"},
                            "Category": "main"
                          }));
                          */
                      await cPI.postContent(
                          phoneNumber, username, encodedImage, "IMAGE");
                      Navigator.pushReplacementNamed(
                        context,
                        '/viewContent',
                      );
                    },
                    child: const Text("PRESS ME TO POST THE IMAGE"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    child: const Text("Return to view content"),
                  ),
                ],
              ),
      ),
    );
  }
}
