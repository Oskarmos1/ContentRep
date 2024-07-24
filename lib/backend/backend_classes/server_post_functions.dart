import 'package:daily/backend/backend_classes/comment.dart';
import 'package:daily/backend/backend_classes/content.dart';

import 'return_value.dart';
import 'user.dart';

class ServerPostFunctions {
  ReturnValue oldUsername(Map<String, User> info, Map<String, User> purgatory,
      Map recieveInfo, Map<String, List<Content>> allContent) {
    // If the user has used the application before and wishes to recover their previous account.
    info[recieveInfo["PhoneNumber"]] =
        User(purgatory[recieveInfo["PhoneNumber"]]!.username, {});
    purgatory.remove(recieveInfo['PhoneNumber']);
    return ReturnValue(info, purgatory, allContent);
  }

  ReturnValue newUsername(Map<String, User> info, Map<String, User> purgatory,
      Map recieveInfo, Map<String, List<Content>> allContent) {
    info[recieveInfo["PhoneNumber"]] = User(recieveInfo["Username"], {});

    return ReturnValue(info, purgatory, allContent);
  }

  ReturnValue killApp(Map<String, User> info, Map<String, User> purgatory,
      Map recieveInfo, Map<String, List<Content>> allContent) {
    if (purgatory[recieveInfo["PhoneNumber"]] == null ||
        info[recieveInfo["PhoneNumber"]] != null) {
      purgatory[recieveInfo["PhoneNumber"]] = info[recieveInfo["PhoneNumber"]]!;
      info.remove(recieveInfo['PhoneNumber']);
    }
    return ReturnValue(info, purgatory, allContent);
  }

  List newPost(
      Map recieveInfo, Map<String, List<Content>> allContent, int contentId) {
    allContent[recieveInfo["Category"]]?.add(Content(
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
        contentId));
    contentId += 1;
    return [allContent, contentId];
  }

  Map<String, List<Content>> likePost(
      Map<String, List<Content>> allContent, int contentId) {
    for (int i = 0; i < allContent["main"]!.length; i++) {
      if (allContent["main"]![i].contentId == contentId) {
        allContent["main"]![i].likes = allContent["main"]![i].likes + 1;
      }
    }
    return allContent;
  }

  Map<String, List<Content>> unLikePost(
      Map<String, List<Content>> allContent, int contentId) {
    for (int i = 0; i < allContent["main"]!.length; i++) {
      if (allContent["main"]![i].contentId == contentId) {
        allContent["main"]![i].likes = allContent["main"]![i].likes - 1;
      }
    }
    return allContent;
  }

  Map<String, List<Content>> dislikePost(
      Map<String, List<Content>> allContent, int contentId) {
    for (int i = 0; i < allContent["main"]!.length; i++) {
      if (allContent["main"]![i].contentId == contentId) {
        allContent["main"]![i].dislikes = allContent["main"]![i].dislikes + 1;
      }
    }
    return allContent;
  }

  Map<String, List<Content>> unDislikePost(
      Map<String, List<Content>> allContent, int contentId) {
    for (int i = 0; i < allContent["main"]!.length; i++) {
      if (allContent["main"]![i].contentId == contentId) {
        allContent["main"]![i].dislikes = allContent["main"]![i].dislikes - 1;
      }
    }
    return allContent;
  }

  List newComment(
      Map<String, List<Content>> allContent, int commentId, Map recieveInfo) {
    for (int i = 0; i < allContent["main"]!.length; i++) {
      if (allContent["main"]![i].contentId ==
          int.parse(recieveInfo["ContentId"])) {
        allContent["main"]![i].comments.add(Comment(
            recieveInfo["Username"],
            recieveInfo["PhoneNumber"],
            recieveInfo["Comment"],
            DateTime.now(),
            commentId));
        commentId += 1;
        allContent["main"]![i].noOfComments += 1;
      }
    }
    return [allContent, commentId];
  }
}


//there is a big problem with moving all the information of the server into a function
