import 'dart:convert';

import 'comment.dart';

class Content {
  Map file;
  String owner;
  String title;
  String description;
  DateTime timeOfPost;
  List<Comment> comments;
  int likes;
  int dislikes;
  int noOfComments;
  List<String> seenBy;
  double contentScore;
  int contentId;
  Content(
      this.file,
      this.owner,
      this.title,
      this.description,
      this.timeOfPost,
      this.comments,
      this.likes,
      this.dislikes,
      this.noOfComments,
      this.seenBy,
      this.contentScore,
      this.contentId);

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'title': title,
      'description': description,
      'owner': owner,
      'timeOfPost': timeOfPost.toIso8601String(),
      'comments': comments,
      'likes': likes,
      'dislikes': dislikes,
      'noOfComments': noOfComments,
      'seenBy': seenBy,
      'contentScore': contentScore,
      'contentId': contentId
    };
  }

  Content fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return Content(
        json['file'],
        json['owner'],
        json['title'],
        json['description'],
        json['timeOfPost'],
        json['comments'],
        json['likes'],
        json['dislikes'],
        json['noOfComments'],
        json['seenBy'],
        json['contentScore'],
        json['contentId']);
  }
}

/*
FormData formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(file.path, filename: 'file.jpg'), // Replace 'file.jpg' with the desired filename
  });
*/
