import 'package:flutter/material.dart';

class CommentWidget extends StatefulWidget {
  final String username;
  final String phoneNumber;
  final String comment;
  final String timeOfComment;
  final int commentId;
  const CommentWidget(
      {super.key,
      required this.username,
      required this.phoneNumber,
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
          Text("Owner Username: ${widget.username}"),
          Text("Owner Phone Number: ${widget.phoneNumber}"),
          Text("Comment: ${widget.comment}"),
          Text("Time of comment: ${widget.timeOfComment}"),
          Text("Comment ID: ${widget.commentId}"),
        ],
      ),
    );
  }
}
