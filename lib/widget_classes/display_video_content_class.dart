import 'dart:io';

//import '../backend_classes/content.dart';
//import '../backend_classes/comment.dart';
import 'package:daily/App/mainApplication/view_content.dart';
import "package:flutter/material.dart";
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
  Duration? savedDuration;
  Image? savedImage;
  // effectively I want to save the image and the duration for when the videoWidget is disposed of
  bool isPlaying = false;
  bool canBeCleared = true;
  bool disposedOf = true;
  VideoPlayerController? loadedVideoFileController;
  dynamic display = Placeholder();
  dynamic scroller = const Placeholder();
  Image? thumbnail;
  late viewContent myView;
  double scrollerOpacity = 0.0;

  void initState() {
    super.initState();
    makeThumbnail(0);
  }

  void makeThumbnail(int ms) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: widget.recievedContent["file"]["File"]["path"],
      imageFormat: ImageFormat.PNG,
      maxHeight:
          100, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
      timeMs: ms,
    );
    File file = File(fileName!);
    thumbnail = Image.file(file);
    display = thumbnail;
    setState(() {});
  }

  void disposeOfThisWidget() {
    if (loadedVideoFileController?.value.isInitialized == true) {
      if (canBeCleared == true) {
        setState(() {
          //makeThumbnail(0);
          display = thumbnail;
          scroller = const Placeholder();
          isPlaying = false;
          disposedOf = true;
          loadedVideoFileController?.dispose();
          scrollerOpacity = 0.0;
        });
      }
    }
  }

  late void Function() killAll;
  @override
  Widget build(BuildContext context) {
    void loadContent() {
      setState(() {
        scrollerOpacity = 1.0;
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
    String title = widget.recievedContent["title"];
    String description = widget.recievedContent["description"];
    String timeOfPost = widget.recievedContent["timeOfPost"].toString();
    //List<Comment> comments = widget.recievedContent["comments"];
    int likes = widget.recievedContent["likes"];
    int dislikes = widget.recievedContent["dislikes"];
    int noOfComments = widget.recievedContent["noOfComments"];

    return Container(
      child: Column(
        children: <Widget>[
          Text(owner),
          Text("TITLE: $title"),
          GestureDetector(
            onTap: () {
              print("I was tapped");
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
            child: SizedBox(
              width: 100,
              height: 100,
              child: display, // Your video widget
            ),
          ),
          Text("DESCRIPTION: $description"),
          Opacity(
            opacity: scrollerOpacity,
            child: SizedBox(
              height: 20,
              width: 200,
              child: scroller,
            ),
          ),
          Text("Time:$timeOfPost"),
          Text("Type:$type"),
          const Text("COMMENTS NOT IMPLEMENTED YET"),
          Text("Likes:$likes"),
          Text("Dislikes:$dislikes"),
          Text("Number of Comments: $noOfComments"),
        ],
      ),
    );
  }
}
