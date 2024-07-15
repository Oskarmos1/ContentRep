import 'dart:io';

//import '../backend_classes/content.dart';
//import '../backend_classes/comment.dart';
import 'package:daily/App/mainApplication/view_content.dart';
import "package:flutter/material.dart";
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final Map recievedContent;
  final void Function() updateOtherVideoWidgets;
  VideoWidget(
      {super.key,
      required this.recievedContent,
      required this.updateOtherVideoWidgets});
  final _VideoWidgetState x = _VideoWidgetState();
  @override
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
  dynamic display = const Placeholder();
  dynamic scroller = const Placeholder();
  late viewContent myView;

  void disposeOfThisWidget() {
    if (loadedVideoFileController?.value.isInitialized == true) {
      if (canBeCleared == true) {
        setState(() {
          display = const Placeholder();
          scroller = const Placeholder();
          isPlaying = false;
          disposedOf = true;
          loadedVideoFileController?.dispose();
        });
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
        scroller = SizedBox(
          width: 200, // or a specific width like 200.0
          child: Opacity(
            child: VideoProgressIndicator(
              loadedVideoFileController!,
              allowScrubbing: true,
            ),
            opacity: 1.0,
          ),
        );
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
          SizedBox(
            height: 250,
            width: 250,
            child: Row(
              children: <Widget>[
                SizedBox(
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
                      style: const TextStyle(fontSize: 6),
                    ))
              ],
            ),
          ),
          /*
          SizedBox(
            width: 200, // or a specific width like 200.0
            child: Opacity(
              child: VideoProgressIndicator(
                loadedVideoFileController!,
                allowScrubbing: true,
              ),
              opacity: 1.0,
            ),
          ),
          */
          SizedBox(
            height: 20,
            width: 200,
            child: scroller,
          ),
          Text("Time:$timeOfPost"),
          Text("Type:$type"),
          const Text("COMMENTS NOT IMPLEMENTED YET"),
          Text("Likes:$likes"),
          Text("Dislikes:$dislikes"),
          Text("Number of Comments: $noOfComments")
        ],
      ),
    );
  }
}
