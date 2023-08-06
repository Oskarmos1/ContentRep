import 'user.dart';
import 'content.dart';

class ReturnValue {
  Map<String, User> info;
  Map<String, User> purgatory;
  Map<String, List<Content>> allContent;
  ReturnValue(this.info, this.purgatory, this.allContent);
}
