import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClientPostInfo {
  Future<bool> postNewUsername(url, phoneNumber, username) async {
    bool returning = true;

    try {
      await http
          .post(Uri.parse("http://192.168.0.19:400"),
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

  Future<bool> postOldUsername(url, phoneNumber) async {
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

  void exitApp(url, phoneNumber, username) async {
    await http.post(Uri.parse("http://192.168.0.19:400"),
        body: jsonEncode({
          "PhoneNumber": phoneNumber,
          "Username": username,
          "Location": "ExitApp"
        }));
  }
}
