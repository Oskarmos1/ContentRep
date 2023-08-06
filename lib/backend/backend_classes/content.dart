import 'comment.dart';
import 'dart:convert';

class Content {
  Map file;
  String owner;
  DateTime timeOfPost;
  List<Comment> comments;
  int likes;
  int dislikes;
  int noOfComments;
  List<String> seenBy;
  double contentScore;
  Content(this.file, this.owner, this.timeOfPost, this.comments, this.likes,
      this.dislikes, this.noOfComments, this.seenBy, this.contentScore);

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'owner': owner,
      'timeOfPost': timeOfPost.toIso8601String(),
      'comments': comments,
      'likes': likes,
      'dislikes': dislikes,
      'noOfComments': noOfComments,
      'seenBy': seenBy,
      'contentScore': contentScore
    };
  }

  Content fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return Content(
        json['file'],
        json['owner'],
        json['timeOfPost'],
        json['comments'],
        json['likes'],
        json['dislikes'],
        json['noOfComments'],
        json['seenBy'],
        json['contentScore']);
  }
}

/*
FormData formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(file.path, filename: 'file.jpg'), // Replace 'file.jpg' with the desired filename
  });
*/
