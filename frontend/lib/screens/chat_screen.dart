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
    'yyyy.MM.dd EEEE',
    'ko',
  ).format(DateTime.now());

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final formattedTime = DateFormat('a hh:mm', 'ko').format(DateTime.now());

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true, time: formattedTime));
    });

    _controller.clear();

    Future.delayed(const Duration(milliseconds: 500), () async {
      final botReply = await _chatBotService.getReply(text);
      final reply = botReply['reply'];
      final safeReply =
          (reply is String && reply.isNotEmpty) ? reply : '응답이 없습니다.';
      setState(() {
        messages.add(
          ChatMessage(
            text: safeReply,
            isUser: false,
            time: '',
            lat: botReply['lat'],
            lng: botReply['lng'],
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // NavigationBar.pop(context);
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop(); // ← 여기서 뒤로가기
                },
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text('새로운 채팅을 시작합니다'),
                        const SizedBox(height: 18),
                        Text(startDate),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                  ...messages.map(
                    (message) => ChatBubble(
                      message: message.text,
                      isUser: message.isUser,
                      time: message.time,
                      lat: message.lat,
                      lng: message.lng,
                    ),
                  ),
                ],
              ),
            ),
            ChatInputField(controller: _controller, onSend: sendMessage),
          ],
        ),
      ),
    );
  }
}
