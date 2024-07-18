import 'dart:io';

import 'package:daily/App/mainApplication/editingFiles/videoEditor.dart';
import 'package:daily/App/serverCommunication/client_post_info.dart';
import 'package:daily/widget_classes/display_video_content_class.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

class EditVideo extends StatefulWidget {
  const EditVideo({super.key});

  @override
  _EditVideoState createState() => _EditVideoState();
}

class _EditVideoState extends State<EditVideo> {
  String title = "";
  String description = "";
  dynamic videoWidget = const Placeholder();
  late XFile pickedFile;
  String? phoneNumber;
  String? username;
  double postButtonOpacity = 0;
  double waitingButtonOpacity = 0;
  bool started = true;
  ClientPostInfo cPI = ClientPostInfo();
  @override
  Widget build(BuildContext context) {
    void updateVideoWidget() {
      setState(() {
        videoWidget = VideoWidget(
          recievedContent: {
            "file": {
              "Type": "VIDEO",
              "File": {"path": pickedFile.path}
            },
            "owner": username,
            "title": title,
            "description": description,
            "timeOfPost": DateTime.now().toString(),
            "likes": 0,
            "dislikes": 0,
            "noOfComments": 0
          },
          updateOtherVideoWidgets: () {},
        );
      });
    }

    List postContentRecievedInfo =
        ModalRoute.of(context)!.settings.arguments as List;

    phoneNumber = postContentRecievedInfo[0][0];
    username = postContentRecievedInfo[0][1];
    if (started == true) {
      pickedFile = postContentRecievedInfo[1];
      updateVideoWidget();
      started = false;
    }

    Future<void> encodeXFileVideo(XFile xFile) async {
      MediaInfo? returning = await VideoCompress.compressVideo(
        xFile.path,
        quality: VideoQuality.LowQuality,
        deleteOrigin: true,
        includeAudio: true,
        frameRate: 5,
      );

      if (returning != null) {
        await cPI.postContent(phoneNumber, username, title, description,
            returning.toJson(), "VIDEO");
      }
      videoWidget.disposeVideoWidget();
      Navigator.pushReplacementNamed(context, '/viewContent');
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Text("TITLE:"),
            TextField(
              onChanged: (value) {
                setState(() {
                  title = value;
                  updateVideoWidget();
                });
              },
            ),
            Text("DESCRIPTION:"),
            TextField(
              onChanged: (value) {
                setState(() {
                  description = value;
                  updateVideoWidget();
                });
              },
            ),
            TextButton(
                onPressed: () async {
                  String originalPath = pickedFile.path;
                  XFile? x = null;
                  videoWidget.disposeVideoWidget();
                  x = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrimmerView(File(pickedFile.path)),
                    ),
                  );
                  print("VALUE OF X: $x");

                  if (x != null) {
                    pickedFile = x;

                    File trimmedFile = File(pickedFile.path);
                    trimmedFile = await trimmedFile.copy(originalPath);
                    pickedFile = XFile(trimmedFile.path);
                    setState(() {
                      postButtonOpacity = 1.0;
                      updateVideoWidget();
                    });
                  }
                },
                child: const Text("Edit the video")),
            videoWidget,
            Opacity(
              opacity: postButtonOpacity,
              child: ElevatedButton(
                onPressed: () {
                  if (waitingButtonOpacity == 0.0) {
                    setState(() {
                      waitingButtonOpacity = 1.0;
                    });

                    encodeXFileVideo(pickedFile);
                  }
                },
                child: const Text("POST VIDEO"),
              ),
            ),
            //if (waitingButtonOpacity > 0)
            Opacity(
              opacity: waitingButtonOpacity,
              child: const Text("UPLOADING..."),
            ),
            TextButton(
              onPressed: () {
                videoWidget.disposeVideoWidget();
                Navigator.pop(context);
              },
              child: const Text("CANCEL"),
            ),
          ],
        ),
      ),
    );
  }
}
