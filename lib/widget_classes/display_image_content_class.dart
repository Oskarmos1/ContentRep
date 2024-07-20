import 'dart:convert';
//import '../backend_classes/content.dart';
//import '../backend_classes/comment.dart';
import 'dart:typed_data';

import 'package:daily/App/serverCommunication/client_post_info.dart';
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
  bool started = true;
  bool liked = false;
  bool disliked = false;
  int? likes;
  int? dislikes;
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
    print("IN DISPLAY IMAGE CONTENT ID: $id");
    String owner = widget.recievedContent["owner"];
    String title = widget.recievedContent["title"];
    String description = widget.recievedContent["description"];
    String timeOfPost = widget.recievedContent["timeOfPost"].toString();
    //List<Comment> comments = widget.recievedContent["comments"];

    int noOfComments = widget.recievedContent["noOfComments"];
    void trial() {
      if (location == "edit_image") {
        LDCOpacity = 0;
      } else {
        LDCOpacity = 1;
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
          Text("ID: $id"),
          Text("TITLE: $title"),
          SizedBox(width: 100, height: 100, child: display),
          Text("DESCRIPTION: $description"),
          Text("Time:$timeOfPost"),
          Text("Type:$type"),
          const Text("COMMENTS NOT IMPLEMENTED YET"),
          Text("Likes:$likes"),
          Text("Dislikes:$dislikes"),
          Text("Number of Comments: $noOfComments"),
          Opacity(
              opacity: LDCOpacity,
              child: TextButton(
                child: Text("Like button"),
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
              )),
          Opacity(
              opacity: LDCOpacity,
              child: TextButton(
                child: Text("Dislike button"),
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
              )),
        ],
      ),
    );
  }
}
