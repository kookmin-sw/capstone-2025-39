import 'package:flutter/material.dart';
import 'package:frontend/screens/chat_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatScreen(), // 임시로 첫 화면으로 지정
    );
  }
}
