import 'dart:async';
import 'dart:convert';

import 'package:daily/backend/backend_classes/content.dart';
import 'package:http/http.dart' as http;

class ClientGetInfo {
  String url = "http://192.168.0.30:400";
  Future<bool?> checkServerStatus(phoneNumber) async {
    try {
      http.Response? information = await http
          .get(Uri.parse(
              "$url?phoneNumber=$phoneNumber&location=${"checkActivity"}"
              ""))
          .timeout(const Duration(seconds: 15));
      bool? direction = jsonDecode(information.body);
      return direction;
    } catch (e) {
      return false;
    }
  }

  Future<List<Content?>> loadingBaseContent(phoneNumber) async {
    late List<Content?> returnContent;
    try {
      http.Response? information = await http
          .get(Uri.parse(
              "$url?phoneNumber=$phoneNumber&location=${"getContent"}"))
          .timeout(const Duration(seconds: 15));
      returnContent = jsonDecode(information.body);
    } catch (e) {
      returnContent = [];
    }

    return returnContent;
  }

  Future<bool> canGetOldAccount(phoneNumber) async {
    late bool canContinue;
    try {
      http.Response? information = await http
          .get(Uri.parse(
              "$url?phoneNumber=$phoneNumber&location=${"canGetOldUsername"}"))
          .timeout(const Duration(seconds: 15));
      canContinue = jsonDecode(information.body);
    } catch (e) {
      return false;
    }
    return canContinue;
  }

  Future<List> getMyCurrentInfo(phoneNumber) async {
    http.Response? information;
    try {
      information = await http.get(Uri.parse(
          "$url?phoneNumber=$phoneNumber&location=${"getMyCurrentInfo"}"));
    } catch (e) {
      return ["Can't get your information"];
    }
    return jsonDecode(information.body);
  }

  Future<List?> getContent(phoneNumber) async {
    print("We got the phone number:$phoneNumber");
    http.Response? information;
    try {
      information = await http.get(
          Uri.parse("$url?phoneNumber=$phoneNumber&location=${"getContent"}"));
    } catch (e) {
      return [];
    }
    return jsonDecode(information.body);
  }
}
