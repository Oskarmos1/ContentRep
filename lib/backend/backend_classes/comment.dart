import 'dart:convert';

class Comment {
  String ownerUsername;
  String ownerPhoneNumber;
  String comment;
  DateTime timeOfComment;
  int commentId;
  Comment(this.ownerUsername, this.ownerPhoneNumber, this.comment,
      this.timeOfComment, this.commentId);

  Map<String, dynamic> toJson() {
    return {
      'ownerUsername': ownerUsername,
      'ownerPhoneNumber': ownerPhoneNumber,
      'comment': comment,
      'timeOfComment': timeOfComment.toIso8601String(),
      'commentId': commentId
    };
  }

  Comment fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return Comment(json['ownerUsername'], json['ownerPhoneNumber'],
        json['comment'], json['timeOfComment'], json['commentId']);
  }
}
