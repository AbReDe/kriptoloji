import 'package:flutter/material.dart';
import 'package:kriptoloji/features/screens/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'kriptoloji',
      theme: ThemeData(
        primaryColor: Colors.blue
      ),
      home:const ChatScreen()
    );
  }
}
