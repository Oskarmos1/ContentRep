import 'dart:convert';

class Comment {
  String username;
  String comment;
  DateTime timeOfComment;
  int commentId;
  Comment(this.username, this.comment, this.timeOfComment, this.commentId);

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'comment': comment,
      'timeOfComment': timeOfComment.toIso8601String(),
      'commentId': commentId
    };
  }

  Comment fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return Comment(json['username'], json['comment'], json['timeOfComment'],
        json['commentId']);
  }
}
