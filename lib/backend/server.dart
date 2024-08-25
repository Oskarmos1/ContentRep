import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:daily/backend/backend_classes/content.dart';

import 'backend_classes/return_value.dart';
import 'backend_classes/server_get_functions.dart';
import 'backend_classes/server_post_functions.dart';
import 'backend_classes/user.dart';

Map<String, User> info = {};
Map<String, User> purgatory = {};
int contentId = 0;
int commentId = 0;
Map<String, List<Content>> allContent = {
  "main": [],
  /*
  "film/cartoon": [],
  "music": [],
  "nature": [],
  "sports": [],
  "vehicles/travel": [],
  "gaming": [],
  "people": [],
  "news": [],
  "education": [],
  "STEM": [],
  "other": [],
  */
};
//
//Images are stored according to which category they belong to. However, the user can sort what type of images they want to see first for example: recommended, most recent, most discussed, most liked, most disliked.
Future<void> handlePost(HttpRequest request) async {
  ServerPostFunctions sPF = ServerPostFunctions();
  var recieved = await utf8.decoder.bind(request).join();
  Map recieveInfo = jsonDecode(recieved);
  if (recieveInfo["Location"] == "UsernameN") {
    ReturnValue returns =
        sPF.newUsername(info, purgatory, recieveInfo, allContent);
    info = returns.info;
    purgatory = returns.purgatory;
  } else if (recieveInfo["Location"] == "UsernameO") {
    ReturnValue returns =
        sPF.oldUsername(info, purgatory, recieveInfo, allContent);
    info = returns.info;
    purgatory = returns.purgatory;
  } else if (recieveInfo["Location"] == "ExitApp") {
    ReturnValue returns = sPF.killApp(info, purgatory, recieveInfo, allContent);
    info = returns.info;
    purgatory = returns.purgatory;
  } else if (recieveInfo["Location"] == "newPost") {
    List returns = sPF.newPost(recieveInfo, allContent, contentId);
    allContent = returns[0];
    contentId = returns[1];
  } else if (recieveInfo["Location"] == "test") {
    for (int i = 0; i < 100; i++) {
      List returns = sPF.newPost(recieveInfo, allContent, contentId);
      allContent = returns[0];
      contentId = returns[1];
    }
  } else if (recieveInfo["Location"] == "Like") {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(sPF.likePost, [
      allContent,
      int.parse(recieveInfo["ContentId"]),
      receivePort.sendPort
    ]);
    allContent = await receivePort.first;
  } else if (recieveInfo["Location"] == "UnLike") {
    ReceivePort receivePort1 = ReceivePort();
    await Isolate.spawn(sPF.unLikePost, [
      allContent,
      int.parse(recieveInfo["ContentId"]),
      receivePort1.sendPort
    ]);
    allContent = await receivePort1.first;
  } else if (recieveInfo["Location"] == "Dislike") {
    ReceivePort receivePort2 = ReceivePort();
    await Isolate.spawn(sPF.dislikePost, [
      allContent,
      int.parse(recieveInfo["ContentId"]),
      receivePort2.sendPort
    ]);
    allContent = await receivePort2.first;
  } else if (recieveInfo["Location"] == "UnDislike") {
    ReceivePort receivePort3 = ReceivePort();
    await Isolate.spawn(sPF.unDislikePost, [
      allContent,
      int.parse(recieveInfo["ContentId"]),
      receivePort3.sendPort
    ]);
    allContent = await receivePort3.first;
  } else if (recieveInfo["Location"] == "NewComment") {
    ReceivePort receivePort4 = ReceivePort();
    await Isolate.spawn(sPF.newComment, [
      allContent,
      commentId,
      recieveInfo,
      int.parse(recieveInfo["ContentId"]),
      receivePort4.sendPort
    ]);
    List returned = await receivePort4.first;
    allContent = returned[0];
    commentId = returned[1];
  }

  /*
  if (allContent["main"]?.isEmpty != true) {
    for (int i = 1; i < allContent["main"]!.length; i++) {
      print("\n");
      Content x = allContent["main"]![i];
      print("ContentId:${x.contentId.toString()}");
      if (allContent["main"]![i].comments.isEmpty != true) {
        Comment comment = allContent["main"]![i].comments[0];
        print(comment.comment);
        print(comment.ownerPhoneNumber);
        print(comment.ownerUsername);
        print(comment.timeOfComment);
        print(comment.commentId.toString());
      }

      print("Likes: ${x.likes.toString()}");
      print("Dislikes: ${x.dislikes.toString()}");
    }
  }
  */
  request.response
    ..statusCode = HttpStatus.ok
    ..write("");
  request.response.close();
}

void handleGet(HttpRequest request) {
  ServerGetFunctions sGF = ServerGetFunctions();
  String phoneNumber = request.uri.queryParameters['phoneNumber']!;
  phoneNumber = phoneNumber.replaceAll(" ", "+");
  String? location = request.uri.queryParameters['location'];
  Object? result;

  if (location == "getContent") {
    result = sGF.getContent(allContent["main"], phoneNumber);
  } else if (location == "checkActivity") {
    result = true;
  } else if (location == "getMyCurrentInfo") {
    if (info[phoneNumber]?.username == null &&
        info[phoneNumber]?.friends == null) {
      info[phoneNumber] = purgatory[phoneNumber]!;
      purgatory.remove(phoneNumber);
    }
    result = sGF.getMyCurrentInfo(info, phoneNumber);
  } else if (location == "canGetOldUsername") {
    result = sGF.canGetOldUsername(purgatory, phoneNumber);
  }

  request.response
    ..write(jsonEncode(result))
    ..close();
}

Future<void> handleRequests(HttpServer server) async {
  await for (HttpRequest request in server) {
    switch (request.method) {
      case 'GET':
        handleGet(request);
        break;
      case 'POST':
        handlePost(request);

        break;
      default:
    }
  }
}

Future<void> main() async {
  final server = await createServer();
  print("Server made on port: ${server.port} address: ${server.address}.");
  await handleRequests(server);
}

Future<HttpServer> createServer() async {
  final address = InternetAddress.anyIPv4;
  const port = 400;
  return await HttpServer.bind(address, port);
}

//Currently won't connect if client is using a vpn
//Occasionaly onStatePaused will not post anything to the server




//FIX LIKING AND DISLIKING POSTS ON SERVER.