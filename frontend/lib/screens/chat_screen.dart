import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import '../services/chatbot_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_field.dart';
import 'package:frontend/services/location_service.dart';

// 챗봇 화면
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

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final formattedTime = DateFormat('a hh:mm', 'ko').format(DateTime.now());

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true, time: formattedTime));
    });

    _controller.clear();

    // 사용자의 위치를 가져오기
    double? lat;
    double? lng;

    final position = await getCurrentLocation();
    if (position != null) {
      lat = position.latitude;
      lng = position.longitude;
      print("위도: $lat, 경도: $lng");
    }

    Future.delayed(const Duration(milliseconds: 500), () async {
      final botReply = await _chatBotService.getReply(text);
      final reply = botReply['reply'];
      final safeReply =
          (reply is String && reply.isNotEmpty) ? reply : '응답이 없습니다.';
      setState(() {
        // 텍스트 응답 추가
        messages.add(ChatMessage(text: safeReply, isUser: false, time: ''));

        //지도 응답이 있으면 별도 말풍선
        if (botReply['lat'] != null && botReply['lng'] != null) {
          messages.add(
            ChatMessage(
              text: '', // 텍스트 없이 지도만
              isUser: false,
              time: '',
              lat: botReply['lat'],
              lng: botReply['lng'],
            ),
          );
        }
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
            const Text(
              '정릉친구',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            // 뒤로가기 버튼
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () async {
                  Navigator.of(context).pop(); // ← 여기서 뒤로가기
                },
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  itemCount: messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          const Text(
                            '새로운 채팅을 시작합니다',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            startDate,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }

                    final message = messages[index - 1];
                    return ChatBubble(
                      message: message.text,
                      isUser: message.isUser,
                      time: message.time,
                      lat: message.lat,
                      lng: message.lng,
                    );
                  },
                ),
              ),
              ChatInputField(controller: _controller, onSend: sendMessage),
            ],
          ),
        ),
      ),
    );
  }
}
