import 'dart:isolate';

import 'comment.dart';
import 'content.dart';
import 'return_value.dart';
import 'user.dart';

class ServerPostFunctions {
  ReturnValue oldUsername(
      Map<String, User> info, Map<String, User> purgatory, Map recieveInfo) {
    // If the user has used the application before and wishes to recover their previous account.
    info[recieveInfo["PhoneNumber"]] =
        User(purgatory[recieveInfo["PhoneNumber"]]!.username);
    purgatory.remove(recieveInfo['PhoneNumber']);
    return ReturnValue(info, purgatory, []);
  }

  ReturnValue newUsername(Map<String, User> info, Map<String, User> purgatory,
      Map recieveInfo, List<Content> allContent) {
    info[recieveInfo["PhoneNumber"]] = User(recieveInfo["Username"]);

    return ReturnValue(info, purgatory, []);
  }

  ReturnValue killApp(
      Map<String, User> info, Map<String, User> purgatory, Map recieveInfo) {
    if (purgatory[recieveInfo["PhoneNumber"]] == null ||
        info[recieveInfo["PhoneNumber"]] != null) {
      purgatory[recieveInfo["PhoneNumber"]] = info[recieveInfo["PhoneNumber"]]!;
      info.remove(recieveInfo['PhoneNumber']);
    }
    return ReturnValue(info, purgatory, []);
  }

  List newPost(Map recieveInfo, List<Content> allContent, int contentId) {
    allContent.add(Content(
        recieveInfo["Post"],
        recieveInfo["Username"],
        recieveInfo["PhoneNumber"],
        recieveInfo["Title"],
        recieveInfo["Description"],
        DateTime.now(),
        [],
        0,
        0,
        0,
        [],
        0.0,
        contentId,
        recieveInfo["Category"]));
    contentId += 1;
    return [allContent, contentId];
  }

  void likePost(List<dynamic> message) {
    List<Content> allContent = message[0];
    int contentId = message[1];
    SendPort sendPort = message[2];
    allContent
        .where((content) => content.contentId == contentId)
        .firstWhere((content) {
      content.likes = content.likes + 1;
      return true;
    });

    sendPort.send(allContent);
  }

  void unLikePost(List<dynamic> message) {
    List<Content> allContent = message[0];
    int contentId = message[1];
    SendPort sendPort = message[2];
    allContent
        .where((content) => content.contentId == contentId)
        .firstWhere((content) {
      content.likes = content.likes - 1;
      return true;
    });

    sendPort.send(allContent);
  }

  void dislikePost(List<dynamic> message) {
    List<Content> allContent = message[0];
    int contentId = message[1];
    SendPort sendPort = message[2];
    allContent
        .where((content) => content.contentId == contentId)
        .firstWhere((content) {
      content.dislikes = content.dislikes + 1;
      return true;
    });

    sendPort.send(allContent);
  }

  void unDislikePost(List<dynamic> message) {
    List<Content> allContent = message[0];
    int contentId = message[1];
    SendPort sendPort = message[2];
    allContent
        .where((content) => content.contentId == contentId)
        .firstWhere((content) {
      content.dislikes = content.dislikes - 1;
      return true;
    });

    sendPort.send(allContent);
  }

  void newComment(List<dynamic> message) {
    List<Content> allContent = message[0];
    int commentId = message[1];
    Map recieveInfo = message[2];
    int contentId = message[3];
    SendPort sendPort = message[4];
    allContent
        .where((content) => content.contentId == contentId)
        .firstWhere((content) {
      content.comments.add(Comment(
          recieveInfo["Username"],
          recieveInfo["PhoneNumber"],
          recieveInfo["Comment"],
          DateTime.now(),
          commentId));
      content.noOfComments += 1;
      return true;
    });
    commentId += 1;
    sendPort.send([allContent, commentId]);
  }
}
