import 'dart:io';
import 'dart:convert';
import 'package:daily/backend/backend_classes/content.dart';
import 'backend_classes/server_post_functions.dart';
import 'backend_classes/server_get_functions.dart';
import 'backend_classes/return_value.dart';
import 'backend_classes/user.dart';

Map<String, User> info = {};
Map<String, User> purgatory = {};
Map<String, List<Content>> allContent = {
  "main": [],
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
};

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
    allContent[recieveInfo["Category"]]?.add(Content(recieveInfo["Post"],
        recieveInfo["Username"], DateTime.now(), [], 0, 0, 0, [], 0.0));
  } else if (recieveInfo["Location"] == "test") {
    for (int i = 0; i < 100; i++) {
      allContent[recieveInfo["Category"]]?.add(Content(
          recieveInfo["Post"],
          info[recieveInfo["PhoneNumber"]]!.username,
          DateTime.now(),
          [],
          i,
          i,
          i,
          [],
          i / 2));
    }
  }

  request.response
    ..statusCode = HttpStatus.ok
    ..write("");
  request.response.close();
}

void handleGet(HttpRequest request) {
  ServerGetFunctions sGF = ServerGetFunctions();
  String? phoneNumber = request.uri.queryParameters['phoneNumber'];
  phoneNumber = phoneNumber?.replaceAll(" ", "+");
  String? location = request.uri.queryParameters['location'];
  Object? result;

  if (location == "getContent") {
    result = sGF.getContent(allContent["main"], phoneNumber);
  } else if (location == "checkActivity") {
    result = true;
  } else if (location == "getMyCurrentInfo") {
    if (info[phoneNumber]?.username == null &&
        info[phoneNumber]?.friends == null) {
      info[phoneNumber!] = purgatory[phoneNumber]!;
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
