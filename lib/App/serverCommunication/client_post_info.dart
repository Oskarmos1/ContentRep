import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ClientPostInfo {
  String url = "http://192.168.0.30:400";
  Future<bool> postNewUsername(phoneNumber, username) async {
    bool returning = true;
    try {
      await http
          .post(Uri.parse(url),
              body: jsonEncode({
                "PhoneNumber": phoneNumber,
                "Username": username,
                "Location": "UsernameN"
              }))
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      returning = false;
    }
    return returning;
  }

  Future<bool> postOldUsername(phoneNumber) async {
    bool returning = true;
    try {
      await http.post(Uri.parse(url),
          body: jsonEncode(
              {"PhoneNumber": phoneNumber, "Location": "UsernameO"}));
    } catch (e) {
      returning = false;
    }
    return returning;
  }

  Future<void> postContent(
      phoneNumber, username, title, description, file, fileType) async {
    await http.post(Uri.parse(url),
        body: jsonEncode({
          "PhoneNumber": phoneNumber,
          "Username": username,
          "Title": title,
          "Description": description,
          "Location": "newPost",
          "Post": {"File": file, "Type": fileType},
          "Category": "main"
        }));
  }

  void exitApp(phoneNumber, username) async {
    await http.post(Uri.parse(url),
        body: jsonEncode({
          "PhoneNumber": phoneNumber,
          "Username": username,
          "Location": "ExitApp"
        }));
  }
}
