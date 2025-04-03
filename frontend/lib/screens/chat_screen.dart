import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import '../services/chatbot_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_field.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ChatBotService _chatBotService = ChatBotService();
  final String startDate = DateFormat(
    'yyy. MM. dd EEEE',
    'ko',
  ).format(DateTime.now());
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final formattedTime = DateFormat('aa hh:mm', 'ko').format(DateTime.now());

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true, time: formattedTime));
    });

    _controller.clear();

    Future.delayed(Duration(milliseconds: 500), () async {
      final botReply = await _chatBotService.getReply(text);
      setState(() {
        messages.add(ChatMessage(text: botReply, isUser: false, time: ''));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // NavigationBar.pop(context); //뒤로가기 기능능
              },
            ),
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/kiki.jpg'),
              radius: 20,
            ),
            SizedBox(width: 8),
            Text(
              '챗봇',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              //메뉴 누르면 새로운 채팅, 설정 등 동작
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
        backgroundColor: Color(0xCE90A891),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text('새로운 채팅을 시작합니다'),
          const SizedBox(height: 18),
          Text(startDate),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              padding: EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final message = messages[index];
                return ChatBubble(
                  message: message.text,
                  isUser: message.isUser,
                  time: message.time,
                );
              },
            ),
          ),
          ChatInputField(controller: _controller, onSend: sendMessage),
        ],
      ),
    );
  }
}
