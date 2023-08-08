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
  bool started = true;
  VideoPlayerController? loadedVideoFileController;
  dynamic display = Placeholder();
  late viewContent myView;

  void disposeOfThisWidget() {
    print("IN DISPOSE OF THIS WIDGET____________________");
    if (loadedVideoFileController != null) {
      if (loadedVideoFileController!.value.isInitialized == true) {
        print("I HAVE BEEN INITIALIZED");
        if (canBeCleared == true) {
          setState(() {
            loadedVideoFileController!.dispose();
            display = Placeholder();
            print("I HAVE BEEN DISPOSED");
          });
        }
        canBeCleared = true;
      }
    }
  }

  late void Function() killAll;
  @override
  Widget build(BuildContext context) {
    if (started == true) {
      loadedVideoFileController = VideoPlayerController.file(
          File(widget.recievedContent["file"]["File"]["path"]))
        ..addListener(() {
          if (mounted) {
            if (loadedVideoFileController!.value.position ==
                loadedVideoFileController!.value.duration) {
              isPlaying = false;
              //loadedVideoFileController.dispose();
            }
            isPlaying = loadedVideoFileController!.value.isPlaying;
          }
        });
      started = false;
    }
    killAll = widget.updateOtherVideoWidgets;
    void loadContent() {
      setState(() {
        loadedVideoFileController!.initialize();

        display = VideoPlayer(loadedVideoFileController!);
      });
    }

//VERY FUCKING CLOSE
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
                      if (isPlaying == false) {
                        isPlaying = true;
                        canBeCleared = false;
                        killAll();
                        if (loadedVideoFileController != null) {
                          if (loadedVideoFileController!.value.isInitialized ==
                              false) {
                            loadContent();
                          }
                        }
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
