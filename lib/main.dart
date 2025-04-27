import 'package:flutter/material.dart';
import 'meme_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meme App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: MemePage(),
    );
  }
}
