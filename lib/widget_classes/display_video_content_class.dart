import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

//import '../backend_classes/content.dart';
//import '../backend_classes/comment.dart';
import 'package:daily/App/mainApplication/view_content.dart';
import 'package:daily/App/serverCommunication/client_post_info.dart';
import 'package:daily/widget_classes/display_comment.dart';
import "package:flutter/material.dart";
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoWidget extends StatefulWidget {
  final Map recievedContent;
  final String location;
  final List myData;
  final void Function() updateOtherVideoWidgets;
  VideoWidget(
      {super.key,
      required this.recievedContent,
      required this.location,
      required this.myData,
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
  bool started = true;
  bool liked = false;
  bool disliked = false;
  int? likes;
  int? dislikes;
  double LDCOpacity = 0;
  double LDCWidth = 0;
  double LDCHeight = 0;
  String newComment = "";
  Duration? savedDuration;
  Image? savedImage;
  // effectively I want to save the image and the duration for when the videoWidget is disposed of
  bool isPlaying = false;
  bool canBeCleared = true;
  bool disposedOf = true;
  VideoPlayerController? loadedVideoFileController;
  dynamic display = Text("No video thumnail loaded");
  dynamic scroller = const Placeholder();
  Image? thumbnail;
  late viewContent myView;
  double scrollerOpacity = 0.0;
  ClientPostInfo cPI = ClientPostInfo();
  late TextEditingController _textController;
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    makeThumbnail(
      0,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<File> saveVideo(videoBytes) async {
    final tempDir = await getTemporaryDirectory();
    File videoFile =
        await File('${tempDir.path}/video.mp4').writeAsBytes(videoBytes);
    return videoFile;
  }

  void makeThumbnail(int ms) async {
    Uint8List videoBytes = base64Decode(widget.recievedContent["file"]["File"]);
    File videoFile = await saveVideo(videoBytes);
    final fileName = await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
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
    void loadContent() async {
      Uint8List videoBytes =
          base64Decode(widget.recievedContent["file"]["File"]);
      File videoFile = await saveVideo(videoBytes);
      setState(() {
        scrollerOpacity = 1.0;
        disposedOf = false;
        //print(widget.recievedContent);
        loadedVideoFileController = VideoPlayerController.file(videoFile)
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
            opacity: 1.0,
            child: VideoProgressIndicator(
              loadedVideoFileController!,
              allowScrubbing: true,
            ),
          ),
        );
      });
    }

    String location = widget.location;
    killAll = widget.updateOtherVideoWidgets;
    String myPhoneNumber = widget.myData[0];
    String myUsername = widget.myData[1];
    String type = widget.recievedContent["file"]["Type"];
    String owner = widget.recievedContent["owner"];
    String title = widget.recievedContent["title"];
    String description = widget.recievedContent["description"];
    String timeOfPost = widget.recievedContent["timeOfPost"].toString();
    String id = widget.recievedContent["contentId"].toString();
    List<dynamic> comments = widget.recievedContent["comments"];
    //List<Comment> comments = widget.recievedContent["comments"];
    //int likes = widget.recievedContent["likes"];
    //int dislikes = widget.recievedContent["dislikes"];
    int noOfComments = widget.recievedContent["noOfComments"];
    void trial() {
      if (location == "edit_video") {
        LDCOpacity = 0;
        LDCWidth = 0;
        LDCHeight = 0;
      } else {
        LDCOpacity = 1;
        LDCWidth = 100;
        LDCHeight = 100;
      }
      likes = widget.recievedContent["likes"];
      dislikes = widget.recievedContent["dislikes"];
      setState(() {});
    }

    if (started == true) {
      started = false;
      trial();
    }
    return Container(
      child: Column(
        children: <Widget>[
          Text(owner),
          Text("TITLE: $title"),
          Text("ID: $id"),
          GestureDetector(
            onTap: () {
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
          Text("Likes:$likes"),
          Text("Dislikes:$dislikes"),
          Text("Number of Comments: $noOfComments"),
          const Text("COMMENTS:"),
          ListView.builder(
            shrinkWrap: true,
            itemCount: comments.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return CommentWidget(
                username: comments[index]["username"],
                comment: comments[index]["comment"],
                timeOfComment: comments[index]["timeOfComment"],
                commentId: comments[index]["commentId"],
              );
            },
          ),
          SizedBox(
              width: LDCWidth,
              height: LDCHeight,
              child: Opacity(
                  opacity: LDCOpacity,
                  child: TextButton(
                    child: const Text("Like button"),
                    onPressed: () {
                      if (LDCOpacity == 1) {
                        if (liked == false) {
                          liked = true;
                          likes = likes! + 1;
                          if (disliked == true) {
                            disliked = false;
                            dislikes = dislikes! - 1;
                            cPI.unDislikePost(myPhoneNumber, myUsername, id);
                          }
                          cPI.likePost(myPhoneNumber, myUsername, id);
                        } else {
                          liked = false;
                          likes = likes! - 1;
                          cPI.unLikePost(myPhoneNumber, myUsername, id);
                        }
                        print(likes);
                        setState(() {});
                      }
                    },
                  ))),
          SizedBox(
              width: LDCWidth,
              height: LDCHeight,
              child: Opacity(
                  opacity: LDCOpacity,
                  child: TextButton(
                    child: const Text("Dislike button"),
                    onPressed: () {
                      if (LDCOpacity == 1) {
                        if (disliked == false) {
                          disliked = true;
                          dislikes = dislikes! + 1;
                          if (liked == true) {
                            liked = false;
                            likes = likes! - 1;
                            cPI.unLikePost(myPhoneNumber, myUsername, id);
                          }
                          cPI.dislikePost(myPhoneNumber, myUsername, id);
                        } else {
                          disliked = false;
                          dislikes = dislikes! - 1;
                          cPI.unDislikePost(myPhoneNumber, myUsername, id);
                        }
                        setState(() {});
                      }
                    },
                  ))),
          SizedBox(
              width: LDCWidth,
              height: LDCHeight,
              child: Opacity(
                  opacity: LDCOpacity,
                  child: TextField(
                    controller: _textController,
                    onChanged: (value) {
                      if (LDCOpacity == 1) {
                        setState(() {
                          newComment = value;
                        });
                      }
                    },
                  ))),
          SizedBox(
              width: LDCWidth,
              height: LDCHeight,
              child: Opacity(
                  opacity: LDCOpacity,
                  child: TextButton(
                      onPressed: () {
                        if (LDCOpacity == 1) {
                          cPI.commentPost(
                              myPhoneNumber, myUsername, id, newComment);
                          setState(() {
                            comments.add({
                              "username": myUsername,
                              "comment": newComment,
                              "timeOfComment": DateTime.now().toString(),
                              "commentId": 69
                            });
                            _textController.clear();
                            newComment = "";
                          });
                        }
                      },
                      child: Text("POST COMMENT $newComment TO SERVER")))),
        ],
      ),
    );
  }
}
