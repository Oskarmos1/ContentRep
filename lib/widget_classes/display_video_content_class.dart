import "package:flutter/material.dart";
//import '../backend_classes/content.dart';
//import '../backend_classes/comment.dart';

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
  bool started = true;
  late VideoPlayerController loadedVideoFileController;
  late VideoPlayer display;

  @override
  Widget build(BuildContext context) {
    String type = widget.recievedContent["file"]["Type"];
    if (started == true) {
      loadedVideoFileController = VideoPlayerController.file(
          File(widget.recievedContent["file"]["File"]["path"]))
        ..addListener(() {
          setState(() {
            isPlaying = loadedVideoFileController.value.isPlaying;
          });
        });
      display = VideoPlayer(loadedVideoFileController);
      loadedVideoFileController.initialize();

      started = false;
    }

    String owner = widget.recievedContent["owner"];
    String timeOfPost = widget.recievedContent["timeOfPost"].toString();
    //List<Comment> comments = widget.recievedContent["comments"];
    int likes = widget.recievedContent["likes"];
    int dislikes = widget.recievedContent["dislikes"];
    int noOfComments = widget.recievedContent["noOfComments"];
    void dispose() {
      loadedVideoFileController.dispose();
      print("DISPOSED OF CONTROLLER");
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
                        isPlaying = true;
                        setState(() {});
                        loadedVideoFileController.play();
                      } else {
                        isPlaying = false;
                        setState(() {});
                        loadedVideoFileController.pause();
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
