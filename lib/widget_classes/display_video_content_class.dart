import "package:flutter/material.dart";
//import '../backend_classes/content.dart';
//import '../backend_classes/comment.dart';
import 'package:daily/App/mainApplication/view_content.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final Map recievedContent;
  final void Function() updateOtherVideoWidgets;
  VideoWidget(
      {super.key,
      required this.recievedContent,
      required this.updateOtherVideoWidgets});
  final _VideoWidgetState x = _VideoWidgetState();
  State createState() {
    return x;
  }

  void disposeVideoWidget() {
    x.disposeOfThisWidget();
  }
}

class _VideoWidgetState extends State<VideoWidget> {
  bool isPlaying = false;
  bool canBeCleared = true;
  bool disposedOf = true;
  VideoPlayerController? loadedVideoFileController;
  dynamic display = Placeholder();
  late viewContent myView;

  void disposeOfThisWidget() {
    if (loadedVideoFileController != null) {
      if (loadedVideoFileController?.value.isInitialized == true) {
        if (canBeCleared == true) {
          setState(() {
            isPlaying = false;
            disposedOf = true;
            loadedVideoFileController?.dispose();
            display = Placeholder();
          });
        }
      }
    }
  }

  late void Function() killAll;
  @override
  Widget build(BuildContext context) {
    void loadContent() {
      setState(() {
        disposedOf = false;
        loadedVideoFileController = VideoPlayerController.file(
            File(widget.recievedContent["file"]["File"]["path"]))
          ..addListener(() {
            if (mounted) {
              isPlaying = loadedVideoFileController!.value.isPlaying;
            }
          });
        loadedVideoFileController?.initialize();
        display = VideoPlayer(loadedVideoFileController!);
      });
    }

    killAll = widget.updateOtherVideoWidgets;

    String type = widget.recievedContent["file"]["Type"];
    String owner = widget.recievedContent["owner"];
    String timeOfPost = widget.recievedContent["timeOfPost"].toString();
    //List<Comment> comments = widget.recievedContent["comments"];
    int likes = widget.recievedContent["likes"];
    int dislikes = widget.recievedContent["dislikes"];
    int noOfComments = widget.recievedContent["noOfComments"];

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
                      canBeCleared = false;
                      killAll();
                      setState(() {
                        canBeCleared = true;
                      });
                      if (disposedOf == true) {
                        loadContent();
                      }

                      if (isPlaying == false) {
                        isPlaying = true;
                        loadedVideoFileController!.play();
                      } else {
                        isPlaying = false;
                        loadedVideoFileController!.pause();
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
