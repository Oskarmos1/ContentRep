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
}
