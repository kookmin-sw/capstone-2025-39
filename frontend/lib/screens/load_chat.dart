import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:frontend/models/chat_message.dart';
import 'package:frontend/services/chatbot_service.dart';
import 'package:frontend/widgets/chat_bubble.dart';
import 'package:frontend/widgets/chat_input_field.dart';
import 'package:frontend/services/location_service.dart';
import 'package:frontend/providers/auth_provider.dart';

class LoadChat extends StatefulWidget {
  final int roomId;
  const LoadChat({super.key, required this.roomId});

  @override
  State<LoadChat> createState() => _LoadChat();
}

class _LoadChat extends State<LoadChat> {
  final List<ChatMessage> messages = [];
  final List<ChatMessage> initialMessages = []; // 기존 메시지
  final TextEditingController _controller = TextEditingController();
  final ChatBotService _chatBotService = ChatBotService();
  bool _isLoading = false;
  late final Dio dio;
  late AuthProvider _auth; // context 접근 대신, auth 변수를 클래스 멤버로 추가하기

  final String startDate = DateFormat(
    'yyyy.MM.dd EEEE',
    'ko',
  ).format(DateTime.now());

  @override
  void initState() {
    super.initState();
    dio = Dio();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessagesFromServer();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _auth = context.read<AuthProvider>();
  }

  Future<void> _loadMessagesFromServer() async {
    // 과거 채팅!!
    print("[LoadChat] ##########과거채팅 시작 !!############");
    setState(() => _isLoading = true);
    final url = 'http://15.165.95.8:8080/api/chat/history/${widget.roomId}';

    try {
      final response = await dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer ${_auth.token}'}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final loaded =
            data
                .map(
                  (m) => ChatMessage(
                    text: m['text'],
                    isUser: m['isUser'],
                    time: m['time'],
                    date: m['date'],
                    lat: m['lat'],
                    lng: m['lng'],
                    roomId: m['roomId'],
                    placeName: m['placeName'],
                  ),
                )
                .toList();

        setState(() {
          initialMessages
            ..clear()
            ..addAll(loaded);
          messages
            ..clear()
            ..addAll(loaded);
        });
      }
    } catch (e) {
      print("[loadMessages] 예외 발생: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> saveMessagesToServer() async {
    final url = 'http://15.165.95.8:8080/api/chat/save';

    // !! 추가된 메시지만 추출 !!
    final newMessages =
        messages.where((m) => !initialMessages.contains(m)).toList();

    if (newMessages.isEmpty) return; // 추가 메시지가 없으면 요청 안 보냄

    final chatList =
        newMessages.map((msg) {
          final map = {
            'text': msg.text,
            'isUser': msg.isUser,
            'time': msg.time,
            'date': msg.date,
            'roomId': msg.roomId,
            'userId': _auth.userId,
          };
          if (msg.lat != null && msg.lng != null) {
            // 디코딩을 해야 제대로 저장됨
            final encoded = utf8.encode(msg.placeName!);
            final decoded = utf8.decode(encoded);
            // print('디코딩 테스트: $decoded');
            map['lat'] = msg.lat;
            map['lng'] = msg.lng;
            map['placeName'] = decoded;
          }
          return map;
        }).toList();
    // 디버깅용: 실제 저장될 메시지들 출력
    print("**[SaveMesages] 요청! 저장될 메시지 목록:");
    for (final m in chatList) {
      print(
        "→ ${m['text']} /n placeName : ${m['placeName']} / lat : ${m['lat']}, lng : ${m['lng']}",
      );
    }
    print("**");

    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_auth.token}',
          },
        ),
        data: chatList,
      );

      if (response.statusCode == 200) {
        print("[SaveMessages] 추가 메시지 저장 완료");
        initialMessages.addAll(newMessages); // 저장 성공 시 초기 메시지 업데이트
      } else {
        print("[SaveMessages] 저장 실패");
      }
    } catch (e) {
      print("[SaveMessages] 예외 발생: $e");
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final formattedTime = DateFormat('a hh:mm', 'ko').format(DateTime.now());
    final token = _auth.token;
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

      // 응답처리!
      // 응답에 위치 정보 포함 시 지도 메시지 추가
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
            placeName: botReply['placeName'],
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    // 어떤 경로든 화면 벗어나면 저장
    saveMessagesToServer(); 
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await saveMessagesToServer(); // 안전하게 저장
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
                    // await saveMessagesToServer();
                    Navigator.pop(context, true);
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
                          return messages.isNotEmpty
                              ? Column(
                                children: [
                                  const Text(
                                    '과거 채팅을 시작합니다',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF3F454D),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    messages[0].date,
                                    style: const TextStyle(
                                      color: Color(0xFF3F454D),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              )
                              : const SizedBox.shrink();
                        }
      
                        final message = messages[index - 1];
                        return ChatBubble(
                          message: message.text,
                          isUser: message.isUser,
                          time: message.time,
                          lat: message.lat,
                          lng: message.lng,
                          placeName: message.placeName,
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
