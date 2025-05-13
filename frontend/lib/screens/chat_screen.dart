import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import 'package:frontend/models/chat_message.dart';
import 'package:frontend/services/chatbot_service.dart';
import 'package:frontend/widgets/chat_bubble.dart';
import 'package:frontend/widgets/chat_input_field.dart';
import 'package:frontend/services/location_service.dart';
import 'package:frontend/providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final int roomId;
  const ChatScreen({super.key, required this.roomId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ChatBotService _chatBotService = ChatBotService();
  bool _isLoading = false;
  late final Dio dio;

  final String startDate = DateFormat(
    'yyyy.MM.dd EEEE',
    'ko',
  ).format(DateTime.now());

  @override
  void initState() {
    super.initState();
    dio = Dio();
    _loadMessagesFromServer();
  }

  Future<void> _loadMessagesFromServer() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final url = 'http://223.130.152.181:8080/api/chat/history/${widget.roomId}';

    try {
      final response = await dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );

      print("[loadMessages] Status: ${response.statusCode}");
      print("[loadMessages] Body: ${response.data}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          messages.clear();
          messages.addAll(
            data.map(
              (m) => ChatMessage(
                text: m['text'],
                isUser: m['user'],
                time: m['time'],
                date: m['date'],
                lat: m['lat'],
                lng: m['lng'],
                roomId: m['roomId'],
              ),
            ),
          );
        });
      } else {
        print("Failed to load messages: ${response.statusCode}");
      }
    } catch (e) {
      print("[loadMessages] 예외 발생: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final formattedTime = DateFormat('a hh:mm', 'ko').format(DateTime.now());
    final auth = context.read<AuthProvider>();
    final token = auth.token;
    final position = await getCurrentLocation();
    final lat = position?.latitude;
    final lng = position?.longitude;

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

    final botReply = await _chatBotService.getReply(
      text,
      token: token,
      lat: lat,
      lng: lng,
      roomId: widget.roomId,
    );

    final replyText = (botReply['reply'] as String?)?.trim() ?? '응답이 없습니다.';

    setState(() {
      messages.add(
        ChatMessage(
          text: replyText,
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
  }

  Future<void> saveMessagesToServer() async {
    final auth = context.read<AuthProvider>();
    final url = 'http://223.130.152.181:8080/api/chat/save';
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
                'userId': auth.userId,
              },
            )
            .toList();

    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${auth.token}',
          },
        ),
        data: chatList,
      );

      print("[SaveMessages] Status: ${response.statusCode}");
      print("[SaveMessages] Body: ${response.data}");

      if (response.statusCode != 200) {
        print("[SaveMessages] 저장 실패");
      }
    } catch (e) {
      print("[SaveMessages] 예외 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await saveMessagesToServer();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
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
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () async {
                    await saveMessagesToServer();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _isLoading
                  ? const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : Expanded(
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
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF3F454D),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                startDate,
                                style: const TextStyle(
                                  color: Color(0xFF3F454D),
                                  fontWeight: FontWeight.w500,
                                ),
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
