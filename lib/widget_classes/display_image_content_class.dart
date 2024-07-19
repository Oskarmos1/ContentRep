import 'dart:convert';
//import '../backend_classes/content.dart';
//import '../backend_classes/comment.dart';
import 'dart:typed_data';

import "package:flutter/material.dart";

class ImageWidget extends StatefulWidget {
  final Map recievedContent;
  const ImageWidget({super.key, required this.recievedContent});

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  @override
  Widget build(BuildContext context) {
    dynamic display;
    String type = widget.recievedContent["file"]["Type"];

    Uint8List bytes = base64.decode(widget.recievedContent["file"]["File"]);
    print(bytes);
    display = Image.memory(bytes);
    String id = widget.recievedContent["contentId"].toString();
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
          Text("ID: $id"),
          Text("TITLE: $title"),
          SizedBox(width: 200, height: 200, child: display),
          Text("DESCRIPTION: $description"),
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
