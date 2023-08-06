import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:daily/App/serverCommunication/client_post_info.dart';
import 'package:daily/App/serverCommunication/client_get_info.dart';

class Username extends StatefulWidget {
  const Username({super.key});

  @override
  State<Username> createState() => _UsernameState();
}

class _UsernameState extends State<Username> {
  String? phoneNumber;
  String? username;
  bool? isActive;
  late bool canGoToViewContent;
  late TextEditingController _controller;
  late bool canContinue;
  ClientPostInfo cPI = ClientPostInfo();
  ClientGetInfo cGI = ClientGetInfo();
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    trial();
  }

  Future<void> trial() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      phoneNumber = prefs.getString('phoneNumber');
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: <Widget>[
          TextField(
            controller: _controller,
            onChanged: (text) {
              setState(() {
                username = text;
              });
            },
          ),
          TextButton(
              child: Text("Sign up as: $username"),
              onPressed: () async {
                isActive = await cGI.checkServerStatus(
                    "http://192.168.0.19:400", phoneNumber);
                if (isActive == true) {
                  print("SERVER IS ACTIVE");
                  if (username != null) {
                    print("POSTED INFORMATION");
                    canGoToViewContent = await cPI.postNewUsername(
                        "http://192.168.0.19:400", phoneNumber, username);
                    if (canGoToViewContent == true) {
                      Navigator.pushReplacementNamed(context, '/viewContent');
                    } else {
                      Navigator.pushReplacementNamed(context, '/noConnection',
                          arguments: "Failed to post info to server.");
                    }
                  }
                } else {
                  Navigator.pushReplacementNamed(context, '/noConnection',
                      arguments: "Failed to connect to server.");
                }
              }),
          TextButton(
              onPressed: () async {
                isActive = await cGI.checkServerStatus(
                    "http://192.168.0.19:400", phoneNumber);
                if (isActive == true) {
                  print("SERVER IS ACTIVE");
                  canContinue = await cGI.canGetOldAccount(
                      "http://192.168.0.19:400", phoneNumber);
                  if (canContinue == true) {
                    canGoToViewContent = await cPI.postOldUsername(
                        "http://192.168.0.19:400", phoneNumber);
                    if (canGoToViewContent == true) {
                      Navigator.pushReplacementNamed(context, '/viewContent');
                    } else {
                      Navigator.pushReplacementNamed(context, '/noConnection',
                          arguments:
                              'Error updating your information on server.');
                    }
                  }
                } else {
                  Navigator.pushReplacementNamed(context, '/noConnection',
                      arguments: "Failed to connect to server.");
                }
              },
              child: Text("Use your previous account"))
        ],
      )),
    );
  }
}
