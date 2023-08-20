import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:daily/App/serverCommunication/client_post_info.dart';

class postContent extends StatefulWidget {
  const postContent({super.key});

  @override
  State<postContent> createState() => _postContentState();
}

class _postContentState extends State<postContent> with WidgetsBindingObserver {
  bool canBeExited = true;
  String? phoneNumber;
  String? username;
  List? displayList;
  ClientPostInfo cPI = ClientPostInfo();

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
          cPI.exitApp("http://192.168.0.19:400", phoneNumber, username);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List viewContentRecievedInfo =
        ModalRoute.of(context)!.settings.arguments as List;
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
                    Navigator.pushReplacementNamed(context, '/editImage',
                        arguments: [viewContentRecievedInfo, pickedFile]);
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
                      arguments: [viewContentRecievedInfo, pickedFile]);
                },
                child: const Text("POST A VIDEO")),
          ],
        ),
      ),
    );
  }
}
