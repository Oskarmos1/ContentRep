import 'package:daily/App/serverCommunication/client_post_info.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class postContent extends StatefulWidget {
  final String? username;

  const postContent({super.key, this.username});

  @override
  State<postContent> createState() => _postContentState();
}

class _postContentState extends State<postContent> with WidgetsBindingObserver {
  bool canBeExited = true;
  String? phoneNumber;
  ClientPostInfo cPI = ClientPostInfo();

  Future<void> trial() async {
    final prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString('phoneNumber');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (canBeExited == true) {
      if (state != AppLifecycleState.resumed) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
          cPI.exitApp("http://192.168.0.19:400", phoneNumber, widget.username);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //[phoneNumber, username]
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TextButton(
                onPressed: () async {
                  canBeExited = false;
                  ImagePicker picker = ImagePicker();
                  XFile? pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    print(
                        "CURRENT USERNAME IN POSTCONTENT: ${widget.username}");
                    Navigator.pushReplacementNamed(context, '/editImage',
                        arguments: [
                          [phoneNumber, widget.username],
                          pickedFile
                        ]);
                  }
                },
                child: const Text("POST AN IMAGE")),
            TextButton(
                onPressed: () async {
                  canBeExited = false;
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickVideo(
                    source: ImageSource.gallery,
                  );
                  Navigator.pushReplacementNamed(context, '/editVideo',
                      arguments: [
                        [phoneNumber, widget.username],
                        pickedFile
                      ]);
                },
                child: const Text("POST A VIDEO")),
            TextButton(
              onPressed: () async {
                Navigator.pop(
                  context,
                );
              },
              child: Text("Return to view content"),
            )
          ],
        ),
      ),
    );
  }
}
