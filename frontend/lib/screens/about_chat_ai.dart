import 'package:flutter/material.dart';

class AboutChatAIScreen extends StatelessWidget {
  const AboutChatAIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About ChatAI')),
      body: const Center(
        child: Text('ChatAI에 대한 소개 페이지입니다.'),
      ),
    );
  }
}
