import 'package:flutter/material.dart';
import 'package:image_viewer/imageview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Viewer',
      home: ImageView(),
    );
  }
}
