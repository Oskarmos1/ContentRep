//import 'dart:core';
import 'message.dart';
//import 'content.dart';

class User {
  String username;
  Map<String, List<Message>> friends;
  User(this.username, this.friends); //, this.myContent);
}
