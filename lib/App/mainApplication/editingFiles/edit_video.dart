import 'dart:convert';
import 'dart:io';

import 'package:daily/App/mainApplication/editingFiles/videoEditor.dart';
import 'package:daily/widget_classes/display_video_content_class.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class EditVideo extends StatefulWidget {
  const EditVideo({Key? key}) : super(key: key);

  @override
  _EditVideoState createState() => _EditVideoState();
}

class _EditVideoState extends State<EditVideo> {
  XFile? pickedFile;
  XFile? outputFile;
  String? phoneNumber;
  String? username;
  double postButtonOpacity = 0;
  double waitingButtonOpacity = 0;
  VideoPlayerController? loadedVideoFileController;
  @override
  Widget build(BuildContext context) {
    List postContentRecievedInfo =
        ModalRoute.of(context)!.settings.arguments as List;
    pickedFile = postContentRecievedInfo[1];
    phoneNumber = postContentRecievedInfo[0][0];
    username = postContentRecievedInfo[0][1];

    void editVideo() async {
      pickedFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoEditor(file: File(pickedFile!.path)),
        ),
      );
      setState(() {
        postButtonOpacity = 1.0;
      });
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
        await http.post(
          Uri.parse("http://192.168.0.19:400"),
          body: jsonEncode({
            "PhoneNumber": phoneNumber,
            "Username": username,
            "Location": "test",
            "Post": {"File": returning.toJson(), "Type": "VIDEO"},
            "Category": "main"
          }),
        );
      }

      Navigator.pushReplacementNamed(context, '/viewContent');
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TextButton(
                onPressed: () {
                  editVideo();
                },
                child: Text("Edit the video")),
            //if (outputFile != null)
            VideoWidget(
              recievedContent: {
                "file": {
                  "Type": "VIDEO",
                  "File": {"path": pickedFile!.path}
                },
                "owner": username,
                "timeOfPost": DateTime.now().toString(),
                "likes": 0,
                "dislikes": 0,
                "noOfComments": 0
              },
              updateOtherVideoWidgets: () {},
            ),
            Opacity(
              opacity: postButtonOpacity,
              child: ElevatedButton(
                onPressed: () {
                  if (waitingButtonOpacity == 0.0) {
                    setState(() {
                      waitingButtonOpacity = 1.0;
                    });
                    encodeXFileVideo(pickedFile!);
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
