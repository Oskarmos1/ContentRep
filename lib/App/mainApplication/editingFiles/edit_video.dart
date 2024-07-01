import 'dart:convert';
import 'dart:io';

import 'package:daily/App/mainApplication/editingFiles/videoEditor.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

class EditVideo extends StatefulWidget {
  const EditVideo({super.key});

  @override
  State<EditVideo> createState() => _EditVideoState();
}

class _EditVideoState extends State<EditVideo> {
  Future<MediaInfo?> encodeXFileVideo(XFile xFile) async {
    MediaInfo? returning = await VideoCompress.compressVideo(
      xFile.path,
      quality: VideoQuality.LowQuality,
      deleteOrigin: true,
      includeAudio: true,
      frameRate: 5,
    );

    return returning;
  }

  double waitingButtonOpacity = 0;
  late XFile pickedFile;
  String? phoneNumber;
  String? username;
  List? displayList;
  double postButtonOpacity = 0;
  XFile? outputFile;
  @override
  Widget build(BuildContext context) {
    void editVideo() async {
      outputFile = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VideoEditor(file: File(pickedFile.path))),
      );
      postButtonOpacity = 1.0;
    }

    List viewContentRecievedInfo =
        ModalRoute.of(context)!.settings.arguments as List;
    pickedFile = viewContentRecievedInfo[1];
    phoneNumber = viewContentRecievedInfo[0][0];
    username = viewContentRecievedInfo[0][1];
    displayList = viewContentRecievedInfo[0][2];

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  editVideo();
                  setState(() {});
                },
                child: Text("PRESS ME TO EDIT THE VIDEO")),
            Opacity(
              opacity: postButtonOpacity,
              child: ElevatedButton(
                onPressed: () async {
                  if (outputFile != null) {
                    if (waitingButtonOpacity == 0.0) {
                      setState(() {
                        waitingButtonOpacity = 1.0;
                      });
                      MediaInfo? encodedVideo =
                          await encodeXFileVideo(outputFile!);

                      print(
                          "$encodedVideo _____________________________________");
                      setState(() {});
                      if (encodedVideo != null) {
                        await http.post(Uri.parse("http://192.168.0.19:400"),
                            body: jsonEncode({
                              "PhoneNumber": phoneNumber,
                              "Username": username,
                              "Location": "test",
                              "Post": {"File": encodedVideo, "Type": "VIDEO"},
                              "Category": "main"
                            }));
                      }

                      Navigator.pushReplacementNamed(context, '/viewContent',
                          arguments: [viewContentRecievedInfo, "editVideo"]);
                    }
                  }
                },
                child: Text("PRESS ME TO POST THE VIDEO"),
              ),
            ),
            Opacity(
              opacity: waitingButtonOpacity,
              child: Text("PLEASE WAIT"),
            )
          ],
        ),
      ),
    );
  }
}
