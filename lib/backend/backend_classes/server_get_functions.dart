import 'package:daily/backend/backend_classes/content.dart';

import 'user.dart';

class ServerGetFunctions {
  /*
  String? recoverAccount(Map<String, User?> info, Map<String, User?> purgatory,
      String? phoneNumber, String? location) {
    return purgatory[phoneNumber]?.username;
  }
*/
  List<Content>? getContent(List<Content>? allContent, String phoneNumber) {
    List<Content>? result;

    if (allContent?.isEmpty == true) {
      result = null;
    } else {
      List<Content>? returnArray = allContent!
          .where((obj) => !obj.seenBy.contains(phoneNumber))
          .toList();
      result = returnArray.toList()
        ..sort((a, b) => b.contentScore.compareTo(a.contentScore));
      if (result.length > 9) {
        result = result.sublist(0, 10);
      } else if (result.length <= 9 && result.isNotEmpty) {
        result = result.sublist(0, result.length);
      }

      for (Content obj in result) {
        obj.seenBy.add(phoneNumber.toString());
      }
    }
    return result;
  }

  List getMyCurrentInfo(info, phoneNumber) {
    return [
      info[phoneNumber]?.username,
      info[phoneNumber]?.friends,
    ];
  }

  bool canGetOldUsername(Map<String, User> purgatory, String? phoneNumber) {
    if (purgatory[phoneNumber] != null) {
      return true;
    } else {
      return false;
    }
  }
}
