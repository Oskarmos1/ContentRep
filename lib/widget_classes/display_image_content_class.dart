import 'dart:convert';
//import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';
//import '../backend_classes/content.dart';
//import '../backend_classes/comment.dart';
import 'dart:typed_data';

import 'package:daily/App/serverCommunication/client_post_info.dart';
import 'package:daily/widget_classes/display_comment.dart';
import "package:flutter/material.dart";

class ImageWidget extends StatefulWidget {
  final Map recievedContent;
  final String location;
  final List myData;
  const ImageWidget(
      {super.key,
      required this.recievedContent,
      required this.location,
      required this.myData});

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  double LDCOpacity = 0;
  double LDCWidth = 0;
  double LDCHeight = 0;
  bool started = true;
  bool liked = false;
  bool disliked = false;
  int? likes;
  int? dislikes;
  String newComment = "";
  late TextEditingController _textController;
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ClientPostInfo cPI = ClientPostInfo();

    dynamic display;
    String type = widget.recievedContent["file"]["Type"];
    String location = widget.location;

    Uint8List bytes = base64.decode(widget.recievedContent["file"]["File"]);
    String myPhoneNumber = widget.myData[0];
    String myUsername = widget.myData[1];
    display = Image.memory(bytes);
    String id = widget.recievedContent["contentId"].toString();
    String ownerUsername = widget.recievedContent["ownerUsername"];
    String ownerPhoneNumber = widget.recievedContent["ownerPhoneNumber"];
    String title = widget.recievedContent["title"];
    String description = widget.recievedContent["description"];
    String timeOfPost = widget.recievedContent["timeOfPost"].toString();
    List<dynamic> comments = widget.recievedContent["comments"];
    int noOfComments = widget.recievedContent["noOfComments"];
    void trial() {
      if (location == "edit_image") {
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
          Text("Owner Username: $ownerUsername"),
          Text("Owner Phone Number: $ownerPhoneNumber"),
          Text("ID: $id"),
          Text("TITLE: $title"),
          SizedBox(width: 100, height: 100, child: display),
          Text("DESCRIPTION: $description"),
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
                username: comments[index]["ownerUsername"],
                phoneNumber: comments[index]["ownerPhoneNumber"],
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
                              "ownerUsername": myUsername,
                              "ownerPhoneNumber": myPhoneNumber,
                              "comment": newComment,
                              "timeOfComment": DateTime.now().toString(),
                              "commentId": 69
                            });
                            _textController.clear();
                            newComment = "";
                          });
                        }
                      },
                      child: Text("POST COMMENT $newComment TO SERVER"))))
        ],
      ),
    );
  }
}
