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
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final int roomId;
  const ChatScreen({super.key, required this.roomId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = []; // 전체 메시지
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

  // 서버에서 지난 대화 기록 불러오기
  Future<void> _loadMessagesFromServer() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final url = 'http://15.165.95.8:8080/api/chat/history/${widget.roomId}';

    try {
      final response = await dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          messages.clear();
          messages.addAll(
            data.map(
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
            ),
          );
        });
      }
    } catch (e) {
      print("[loadMessages] 예외 발생: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 사용자 메시지 + 챗봇 답변 받기
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final formattedTime = DateFormat('a hh:mm', 'ko').format(DateTime.now());
    final auth = context.read<AuthProvider>();
    final token = auth.token;
    final position = await getCurrentLocation();
    final lat = position?.latitude;
    final lng = position?.longitude;
    // 로그인을 안 한 경우 대화 제한
    if (token == null) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.black, width: 1), // 검정 테두리
              ),
              title: Text(
                "로그인 필요",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              content: Text("채팅을 사용하려면 먼저 로그인해주세요."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("확인"),
                ),
              ],
            ),
      );
      return;
    }

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

    // 챗봇 응답 가져오기!! (응답 받기 위해 보낼 변수들)
    final botReply = await _chatBotService.getReply(
      text,
      token: token,
      lat: lat,
      lng: lng,
      roomId: widget.roomId,
    );

    final replyText = (botReply['reply'] as String?)?.trim() ?? '응답이 없습니다.';
    // 토큰 만료된 경우 처리
    if (botReply['error'] == 'unauthorized') {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text("세션 만료"),
              content: Text("로그인 세션이 만료되었습니다. 다시 로그인해주세요."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // 로그인 화면으로 이동 (예: named route 사용)
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text("확인"),
                ),
              ],
            ),
      );
      return;
    }
    setState(() {
      // 챗봇 답변 추가
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

  // 전체 메시지 서버에 저장 (replace 방식)
  Future<void> saveMessagesToServer() async {
    final auth = context.read<AuthProvider>();
    final url = 'http://15.165.95.8:8080/api/chat/save';
    print("saveMessagesToServer() 호출!!");

    final chatList =
        messages.map((msg) {
          final map = {
            'text': msg.text,
            'isUser': msg.isUser,
            'time': msg.time,
            'date': msg.date,
            'roomId': msg.roomId,
            'userId': auth.userId,
          };
          // lat, lng이 null인 경우 포함
          if (msg.lat != null && msg.lng != null) {
            // 디코딩을 해야 제대로 저장됨됨
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
            'Authorization': 'Bearer ${auth.token}',
          },
        ),
        data: chatList,
      );

      print("[SaveMessages] 응답 상태 코드: ${response.statusCode}");
      print("[SaveMessages] 응답 본문: ${response.data}");

      if (response.statusCode != 200) {
        print("[SaveMessages] 저장 실패");
      } else {
        print("[SaveMessages] 저장 성공");
      }
    } catch (e) {
      if (e is DioException) {
        print("[SaveMessages] DioError 발생: ${e.response?.statusCode}");
        print("[SaveMessages] DioError 응답 본문: ${e.response?.data}");
      } else {
        print("[SaveMessages] 예외 발생: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 시 전체 메시지 서버에 저장
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
              // 타이틀
              const Text(
                '정릉친구',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              // 뒤로가기 버튼
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
              // 로딩 중이면 로딩 표시
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
                          // 대화 시작 안내 + 날짜
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

                        // 메시지 출력
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
              // 입력창
              ChatInputField(controller: _controller, onSend: sendMessage),
            ],
          ),
        ),
      ),
    );
  }
}
