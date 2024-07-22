import 'package:flutter/material.dart';

class CommentWidget extends StatefulWidget {
  final String username;
  final String comment;
  final String timeOfComment;
  final int commentId;
  const CommentWidget(
      {super.key,
      required this.username,
      required this.comment,
      required this.timeOfComment,
      required this.commentId});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text("Username: " + widget.username),
          Text("Comment: " + widget.comment),
          Text("Time of comment: " + widget.timeOfComment.toString()),
          Text("Comment ID: " + widget.commentId.toString()),
        ],
      ),
    );
  }
}
