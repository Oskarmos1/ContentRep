import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

class _EditVideoState extends State<EditVideo> with WidgetsBindingObserver {
  String title = "";
  String description = "";
  dynamic videoWidget = const Text("No video thumnail loaded");
  late XFile pickedFile;
  String? phoneNumber;
  String? username;
  double postButtonOpacity = 0;
  double waitingButtonOpacity = 0;
  bool started = true;
  ClientPostInfo cPI = ClientPostInfo();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    videoWidget.disposeVideoWidget();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
        await cPI.exitApp(phoneNumber, username);
      }
    }
    //}
  }

  @override
  Widget build(BuildContext context) {
    void updateVideoWidget() async {
      Uint8List x = await File(pickedFile.path).readAsBytes();
      setState(() {
        videoWidget = VideoWidget(
          recievedContent: {
            "file": {"Type": "VIDEO", "File": base64Encode(x)},
            "ownerUsername": username,
            "ownerPhoneNumber": phoneNumber,
            "title": title,
            "description": description,
            "timeOfPost": DateTime.now().toString(),
            "likes": 0,
            "dislikes": 0,
            "comments": [
              {
                "comment": "There are no comments",
                "timeOfComment": DateTime.now().toString(),
                "ownerUsername": "!!!!!!!!",
                "ownerPhoneNumber": phoneNumber,
                "commentId": 69
              }
            ],
            "contentId": "Will be given by server",
            "noOfComments": 0
          },
          location: "edit_video",
          myData: [phoneNumber!, username!],
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
      if (mounted) {
        MediaInfo? z = await VideoCompress.compressVideo(
          xFile.path,
          quality: VideoQuality.LowQuality,
          deleteOrigin: true,
          includeAudio: true,
          frameRate: 5,
        );
        if (z != null && z.path != null) {
          Uint8List x = await File(z.path!).readAsBytes();
          String returning = base64Encode(x);
          //print("ME MF:" + returning!.toJson().toString());
          await cPI.postContent(
              phoneNumber, username, title, description, returning, "VIDEO");
        }

        videoWidget.disposeVideoWidget();

        Navigator.pushReplacementNamed(
          context,
          '/viewContent',
        );
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Text("TITLE:"),
            TextField(
              onChanged: (value) {
                setState(() {
                  title = value;
                  updateVideoWidget();
                });
              },
            ),
            const Text("DESCRIPTION:"),
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
                  if (mounted) {
                    String originalPath = pickedFile.path;
                    XFile? x;
                    videoWidget.disposeVideoWidget();

                    x = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TrimmerView(File(pickedFile.path)),
                      ),
                    );

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
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("CANCEL"),
            ),
          ],
        ),
      ),
    );
  }
}
// when the video is playing and is edited, that is when errors occur.