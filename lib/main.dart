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
