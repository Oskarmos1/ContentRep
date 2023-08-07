import 'dart:io';

import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:daily/App/serverCommunication/client_post_info.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

class postContent extends StatefulWidget {
  const postContent({super.key});

  @override
  State<postContent> createState() => _postContentState();
}

Future<String> encodeXFileToBase64(XFile xFile) async {
  // Read the file as a list of bytes
  Uint8List fileBytes = await xFile.readAsBytes();
  late Uint8List compressedBytes;
  // Compress the image using flutter_image_compress
  compressedBytes = await FlutterImageCompress.compressWithList(
    fileBytes,
    minHeight: 500, // Set minimum height (optional)
    minWidth: 500, // Set minimum width (optional)
    quality: 80, // Set compression quality (0-100)
  );
  XFile compressedFile = XFile.fromData(compressedBytes);

  List<int> imageBytes = await compressedFile.readAsBytes();
  String base64Image = base64Encode(imageBytes);
  return base64Image;
}

Future<MediaInfo?> encodeXFileVideo(XFile xFile) async {
  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<ByteData> convertXFileToByteData(XFile xFile) async {
    File file = File(xFile.path);
    Uint8List bytes = await file.readAsBytes();
    return ByteData.sublistView(bytes);
  }

  MediaInfo? returning;

  VideoPlayerController testlengthcontroller =
      new VideoPlayerController.file(File(xFile.path));
  await testlengthcontroller.initialize();

  if (testlengthcontroller.value.duration.inSeconds > 15) {
    //XFile? trimmedVideo = await trimAndSaveVideo(xFile, 0, 15);
    final appDirectory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final outputPath = '${appDirectory?.path}/out_file.mp4';

    const filename = "x.mp4";
    //var bytes = await rootBundle.load("assets/x.mp4");
    ByteData bytes = await convertXFileToByteData(xFile);
    String dir = (await getApplicationDocumentsDirectory()).path;
    writeToFile(bytes, '$dir/$filename');
    final session = await FFmpegKit.execute(
        '-ss 0:00:00 -to 0:00:15 -y -i ${'$dir/$filename'} -filter:v "crop=320:150" -c:a copy $outputPath');
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      returning = await VideoCompress.compressVideo(
        outputPath,
        quality: VideoQuality.LowQuality,
        deleteOrigin: true,
        includeAudio: true,
        frameRate: 5,
        startTime: 0,
      );
    } else if (ReturnCode.isCancel(returnCode)) {
      print("Cancel");
    } else {
      print("Error");
      final failStackTrace = await session.getFailStackTrace();
      print(failStackTrace);
      List logs = await session.getLogs();
      for (var element in logs) {
        print(element.getMessage());
      }
    }
  } else {
    returning = await VideoCompress.compressVideo(
      xFile.path,
      quality: VideoQuality.LowQuality,
      deleteOrigin: true,
      includeAudio: true,
      frameRate: 5,
    );
  }

  return returning;
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
    phoneNumber = viewContentRecievedInfo[0];
    username = viewContentRecievedInfo[1];
    displayList = viewContentRecievedInfo[2];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TextButton(
                onPressed: () async {
                  canBeExited = false;
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    String encodedImage = await encodeXFileToBase64(pickedFile);
                    try {
                      await http.post(Uri.parse("http://192.168.0.19:400"),
                          body: jsonEncode({
                            "PhoneNumber": phoneNumber,
                            "Username": username,
                            "Location": "test",
                            "Post": {"File": encodedImage, "Type": "IMAGE"},
                            "Category": "main"
                          }));
                      canBeExited = true;
                    } catch (e) {
                      canBeExited = true;
                    }

                    Navigator.pushReplacementNamed(context, '/viewContent',
                        arguments: displayList);
                  }
                },
                child: Text("POST AN IMAGE")),
            TextButton(
                onPressed: () async {
                  canBeExited = false;
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickVideo(
                    source: ImageSource.gallery,
                  );
                  print("IMAGE PICKED ________________________________");
                  if (pickedFile != null) {
                    MediaInfo? encodedVideo =
                        await encodeXFileVideo(pickedFile);
                    setState(() {});
                    if (encodedVideo != null) {
                      try {
                        await http.post(Uri.parse("http://192.168.0.19:400"),
                            body: jsonEncode({
                              "PhoneNumber": phoneNumber,
                              "Username": username,
                              "Location": "test",
                              "Post": {"File": encodedVideo, "Type": "VIDEO"},
                              "Category": "main"
                            }));
                        canBeExited = true;
                      } catch (e) {
                        canBeExited = true;
                      }
                    }

                    Navigator.pushReplacementNamed(context, '/viewContent',
                        arguments: displayList);
                  }
                },
                child: Text("POST A VIDEO")),
          ],
        ),
      ),
    );
  }
}
