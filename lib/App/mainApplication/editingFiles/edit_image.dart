import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';

import 'package:image_editor_plus/image_editor_plus.dart';

class EditImage extends StatefulWidget {
  const EditImage({super.key});

  @override
  State<EditImage> createState() => _EditImageState();
}

class _EditImageState extends State<EditImage> {
  Future<String> encodeXFileToBase64(Uint8List fileBytes) async {
    // Read the file as a list of bytes
    late Uint8List compressedBytes;
    // Compress the image using flutter_image_compress
    compressedBytes = await FlutterImageCompress.compressWithList(
      fileBytes,
      minHeight: 500, // Set minimum height (optional)
      minWidth: 500, // Set minimum width (optional)
      quality: 80, // Set compression quality (0-100)
    );
    XFile compressedFile = XFile.fromData(compressedBytes);

    List<int> imageBytes = await compressedFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  bool started = true;
  late XFile pickedFile;
  String? phoneNumber;
  String? username;
  List? displayList;
  Uint8List? fileBytes;
  Uint8List? finalFileBytes;
  dynamic displayImage = Placeholder();
  @override
  Widget build(BuildContext context) {
    List viewContentRecievedInfo =
        ModalRoute.of(context)!.settings.arguments as List;
    pickedFile = viewContentRecievedInfo[1];
    phoneNumber = viewContentRecievedInfo[0][0];
    username = viewContentRecievedInfo[0][1];
    displayList = viewContentRecievedInfo[0][2];
    void trial() async {
      fileBytes = await pickedFile.readAsBytes();
      setState(() {
        displayImage = Image.memory(fileBytes!);
      });
    }

    if (started) {
      setState(() {
        trial();
        started = false;
      });
    }

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            ElevatedButton(
              child: const Text("ImageEditor"),
              onPressed: () async {
                Uint8List? editedImage = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageEditor(
                      image: fileBytes,
                    ),
                  ),
                );

                // replace with edited image
                if (editedImage != null) {
                  finalFileBytes = editedImage;
                  displayImage = Image.memory(finalFileBytes!);
                  setState(() {});
                }
              },
            ),
            displayImage,
            ElevatedButton(
                onPressed: () async {
                  if (finalFileBytes == null) {
                    finalFileBytes = fileBytes;
                  }
                  String encodedImage =
                      await encodeXFileToBase64(finalFileBytes!);

                  await http.post(Uri.parse("http://192.168.0.19:400"),
                      body: jsonEncode({
                        "PhoneNumber": phoneNumber,
                        "Username": username,
                        "Location": "test",
                        "Post": {"File": encodedImage, "Type": "IMAGE"},
                        "Category": "main"
                      }));

                  Navigator.pushReplacementNamed(context, '/viewContent',
                      arguments: displayList);
                },
                child: Text("PRESS ME TO POST THE IMAGE"))
          ],
        ),
      ),
    );
  }
}
