import 'package:daily/App/mainApplication/editingFiles/edit_image.dart';
import 'package:daily/App/mainApplication/editingFiles/edit_video.dart';
import 'package:daily/App/mainApplication/post_content.dart';
import 'package:daily/App/setup/no_connection.dart';
import 'package:daily/App/setup/sign_up.dart';
import 'package:flutter/material.dart';

import 'App/mainApplication/view_content.dart';
import 'App/setup/loading.dart';
import 'App/setup/username.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const loading(),
      '/signUp': (context) => const signUp(),
      '/userName': (context) => const Username(),
      '/viewContent': (context) => const viewContent(),
      '/postContent': (context) => const postContent(),
      '/noConnection': (context) => const noConnection(),
      '/editImage': (context) => const EditImage(),
      '/editVideo': (context) => const EditVideo(),
    },
  ));
}

//Must remember to set up ads for ios as well.
//Must remember to have the posts saved when entering other screens in the application


//git add .
//git commit -m ""
//git push -u origin main

//WIRELESS DEBUGGING: https://www.youtube.com/watch?v=msaloE7CLYo; IP ADDRESS: 192.168.0.58; PORT: 59513