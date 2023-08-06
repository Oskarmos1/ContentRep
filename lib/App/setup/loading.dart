import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:daily/App/serverCommunication/client_get_info.dart';

class loading extends StatefulWidget {
  @override
  const loading({super.key});

  @override
  State<loading> createState() => _loadingState();
}

//exceptions can't be caught in the build phase
class _loadingState extends State<loading> {
  double failOpacity = 0.0;
  bool? direction = true;

  ClientGetInfo cGI = ClientGetInfo();
  @override
  void initState() {
    super.initState();
    trial();
  }

  void trial() async {
    final prefs = await SharedPreferences.getInstance();
    final String? phoneNumber = prefs.getString('phoneNumber');
    if (phoneNumber == null) {
      Navigator.pushReplacementNamed(context, '/signUp');
    } else {
      direction =
          await cGI.checkServerStatus("http://192.168.0.19:400", phoneNumber);
      if (direction == true) {
        Navigator.pushReplacementNamed(context, '/userName');
      } else {
        setState(() {
          failOpacity = 1.0;
        });
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Text("Loading"),
          Text(
            "Failed to load",
            style: TextStyle(color: Colors.black.withOpacity(failOpacity)),
          ),
          Opacity(
            opacity: failOpacity,
            child: TextButton(
                onPressed: () {
                  if (direction == false) {
                    Navigator.pushReplacementNamed(
                      context,
                      '/',
                    );
                  }
                },
                child: Text(
                  "Please try again",
                )),
          )
        ],
      )),
    );
  }
}
