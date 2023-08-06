import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:daily/backend/backend_classes/content.dart';

class ClientGetInfo {
  Future<bool?> checkServerStatus(url, phoneNumber) async {
    try {
      http.Response? information = await http
          .get(Uri.parse(
              "$url?phoneNumber=$phoneNumber&location=${"checkActivity"}"
              ""))
          .timeout(Duration(seconds: 15));
      bool? direction = jsonDecode(information.body);
      return direction;
    } catch (e) {
      return false;
    }
  }

  Future<List<Content?>> loadingBaseContent(url, phoneNumber) async {
    late List<Content?> returnContent;
    try {
      http.Response? information = await http
          .get(Uri.parse(
              "$url?phoneNumber=${phoneNumber}&location=${"getContent"}"))
          .timeout(Duration(seconds: 15));
      returnContent = jsonDecode(information.body);
    } catch (e) {
      returnContent = [];
    }

    return returnContent;
  }

  Future<bool> canGetOldAccount(url, phoneNumber) async {
    late bool canContinue;
    try {
      http.Response? information = await http
          .get(Uri.parse(
              "$url?phoneNumber=$phoneNumber&location=${"canGetOldUsername"}"))
          .timeout(Duration(seconds: 15));
      canContinue = jsonDecode(information.body);
    } catch (e) {
      return false;
    }
    return canContinue;
  }

  Future<List> getMyCurrentInfo(url, phoneNumber) async {
    http.Response? information;
    print("GETTING MY CURRENT INFO");
    try {
      information = await http.get(Uri.parse(
          "$url?phoneNumber=$phoneNumber&location=${"getMyCurrentInfo"}"));
    } catch (e) {
      return ["Can't get your information"];
    }
    print("INFO: ${jsonDecode(information.body)}");
    return jsonDecode(information.body);
  }

  Future<List?> getContent(url, phoneNumber) async {
    print("GETTING CONTENT");
    http.Response? information;
    try {
      information = await http.get(Uri.parse(
          "http://192.168.0.19:400?phoneNumber=$phoneNumber&location=${"getContent"}"));
    } catch (e) {
      return [];
    }
    print("INFO: ${jsonDecode(information.body)}");
    return jsonDecode(information.body);
  }
}
