//import 'dart:core';
import 'message.dart';
//import 'content.dart';

class User {
  String username;
  Map<String, List<Message>> friends;
  //List<Content>? myContent;
  User(this.username, this.friends); //, this.myContent);
}
