import 'package:flutter/material.dart';

class noConnection extends StatefulWidget {
  const noConnection({super.key});

  @override
  State<noConnection> createState() => _noConnectionState();
}

class _noConnectionState extends State<noConnection> {
  @override
  Widget build(BuildContext context) {
    //String errorText = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: <Widget>[
          //Text(errorText),
          TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/userName');
                }
              },
              child: const Text("Return to username"))
        ],
      ),
    ));
  }
}

//When using a vpn - it immediately sends you to no connection to server
//When using mobile data - it times out and sends you to no connection to server
//When connected to different networks (server and client) - works well
//When connected to the same network - works well
