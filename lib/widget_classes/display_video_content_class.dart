import "package:flutter/material.dart";
//import '../backend_classes/content.dart';
//import '../backend_classes/comment.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final Map recievedContent;
  const VideoWidget({super.key, required this.recievedContent});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  bool isPlaying = false;
  late VideoPlayerController loadedVideoFileController;
  @override
  Widget build(BuildContext context) {
    dynamic display;
    String type = widget.recievedContent["file"]["Type"];

    if (type == "IMAGE") {
      Uint8List bytes = base64.decode(widget.recievedContent["file"]["File"]);
      display = Image.memory(bytes);
    } else if (type == "VIDEO") {
      loadedVideoFileController = VideoPlayerController.file(
          File(widget.recievedContent["file"]["File"]["path"]));
      loadedVideoFileController.play();
      display = VideoPlayer(loadedVideoFileController);
      loadedVideoFileController.initialize();
    }

    String owner = widget.recievedContent["owner"];
    String timeOfPost = widget.recievedContent["timeOfPost"].toString();
    //List<Comment> comments = widget.recievedContent["comments"];
    int likes = widget.recievedContent["likes"];
    int dislikes = widget.recievedContent["dislikes"];
    int noOfComments = widget.recievedContent["noOfComments"];
    void dispose() {
      loadedVideoFileController.dispose();
      super.dispose();
    }

    return Container(
      child: Column(
        children: <Widget>[
          Text(owner),
          Container(
            height: 250,
            width: 250,
            child: Row(
              children: <Widget>[
                Container(
                  height: 150,
                  width: 150,
                  child: display,
                ),
                TextButton(
                    onPressed: () {
                      if (isPlaying == false) {
                        loadedVideoFileController.play();
                        setState(() {
                          isPlaying = true;
                        });
                      } else {
                        loadedVideoFileController.pause();
                        setState(() {
                          isPlaying = false;
                        });
                      }
                    },
                    child: Text(
                      "ChangeVideoState:$isPlaying",
                      style: TextStyle(fontSize: 6),
                    ))
              ],
            ),
          ),
          Text("Time:$timeOfPost"),
          Text("Type:$type"),
          Text("COMMENTS NOT IMPLEMENTED YET"),
          Text("Likes:$likes"),
          Text("Dislikes:$dislikes"),
          Text("Number of Comments: $noOfComments")
        ],
      ),
    );
  }
}
