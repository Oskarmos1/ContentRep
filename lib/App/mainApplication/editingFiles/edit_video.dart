import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:daily/App/serverCommunication/client_post_info.dart';
import 'package:video_compress/video_compress.dart';
import 'package:flutter/services.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:path_provider/path_provider.dart';

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

  late XFile pickedFile;
  String? phoneNumber;
  String? username;
  List? displayList;
  @override
  Widget build(BuildContext context) {
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
            FloatingActionButton(
              onPressed: () async {
                if (pickedFile != null) {
                  MediaInfo? encodedVideo = await encodeXFileVideo(pickedFile);

                  print("$encodedVideo _____________________________________");
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
                      arguments: displayList);
                }
              },
              child: Text("PRESS ME TO POST THE VIDEO"),
            )
          ],
        ),
      ),
    );
  }
}

/*         




*/