import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../services/chatbot_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_field.dart';
import 'package:frontend/services/location_service.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// 챗봇 화면
class ChatScreen extends StatefulWidget {
  final int roomId;
  const ChatScreen({super.key, required this.roomId});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ChatBotService _chatBotService = ChatBotService();
  final box = Hive.box<ChatMessage>('chatBox');

  final String startDate = DateFormat(
    'yyyy.MM.dd EEEE',
    'ko',
  ).format(DateTime.now());

  @override
  void initState() {
    super.initState();
    // Hive에서 roomId에 해당하는 메시지만 불러오기
    final saved =
        box.values.where((msg) => msg.roomId == widget.roomId).toList();
    messages.addAll(saved);
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final formattedTime = DateFormat('a hh:mm', 'ko').format(DateTime.now());

    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          time: formattedTime,
          date: startDate,
          roomId: widget.roomId,
        ),
      );
    });

    _controller.clear();

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
        messages.add(
          ChatMessage(
            text: safeReply,
            isUser: false,
            time: '',
            date: startDate,
            roomId: widget.roomId,
          ),
        );

        if (botReply['lat'] != null && botReply['lng'] != null) {
          messages.add(
            ChatMessage(
              text: '',
              isUser: false,
              time: '',
              date: startDate,
              lat: botReply['lat'],
              lng: botReply['lng'],
              roomId: widget.roomId,
            ),
          );
        }
      });
    });
  }

  // Hive(flutter local storage)에 메세지 저장
  Future<void> saveMessagesToHive() async {
    final keysToDelete =
        box.keys.where((key) {
          final msg = box.get(key);
          return msg is ChatMessage && msg.roomId == widget.roomId;
        }).toList();

    await box.deleteAll(keysToDelete);

    for (var msg in messages) {
      await box.add(msg);
    }
  }

  // 서버에 메세지 저장
  Future<void> saveMessagesToServer() async {
    final url = Uri.parse('http://223.130.152.181:8080/api/chat/save');

    final chatList =
        messages
            .map(
              (msg) => {
                'text': msg.text,
                'isUser': msg.isUser,
                'time': msg.time,
                'date': msg.date,
                'lat': msg.lat,
                'lng': msg.lng,
                'roomId': msg.roomId,
              },
            )
            .toList();

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'messages': chatList}),
    );

    if (response.statusCode == 200) {
      print('서버 저장 성공');
    } else {
      print('서버 저장 실패: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Provider.of<AuthProvider>(context).isLoggedIn;
    String? token = Provider.of<AuthProvider>(context).token;

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
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () async {
                  final auth = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  if (auth.isLoggedIn) {
                    await saveMessagesToServer();
                  } else {
                    await saveMessagesToHive();
                  }
                  Navigator.of(context).pop();
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
