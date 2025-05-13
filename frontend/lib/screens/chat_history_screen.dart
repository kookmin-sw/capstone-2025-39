import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import 'package:frontend/models/chat_message.dart';
import 'chat_screen.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:frontend/providers/auth_provider.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  Map<int, ChatMessage> previews = {};
  late final Dio dio;

  @override
  void initState() {
    super.initState();
    dio = Dio();
    _loadPreviewsFromServer();
  }

  // 전체 채팅 기록을 서버에서 가져오는 메서드
  Future<void> _loadPreviewsFromServer() async {
    final auth = context.read<AuthProvider>();
    final url = 'http://223.130.152.181:8080/api/chat/rooms';

    try {
      final response = await dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );

      print("[HistoryLoad] -> 응답 상태 코드: ${response.statusCode}");
      print("[HistoryLoad] -> 응답 본문: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // roomId별 최신 메시지만 저장
        Map<int, ChatMessage> latestByRoom = {};

        for (var item in data) {
          final msg = ChatMessage(
            text: item['text'],
            isUser: item['user'],
            time: item['time'],
            date: item['date'],
            lat: item['lat'],
            lng: item['lng'],
            roomId: item['roomId'],
          );

          if (!latestByRoom.containsKey(msg.roomId) ||
              msg.time.compareTo(latestByRoom[msg.roomId]!.time) > 0) {
            latestByRoom[msg.roomId] = msg;
          }
        }

        setState(() {
          previews = latestByRoom;
        });
      }
    } catch (e) {
      print('불러오기 실패: $e');
    }
  }

  // 채팅방 삭제 메서드
  Future<bool> deleteRoom(int roomId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('기록 삭제'),
            content: const Text('이 채팅 기록을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('삭제'),
              ),
            ],
          ),
    );

    if (confirmed ?? false) {
      final auth = context.read<AuthProvider>();
      final url = 'http://223.130.152.181:8080/api/chat/delete/$roomId';

      try {
        final response = await dio.delete(
          url,
          options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
        );

        print("[DeleteRoom] -> 응답 상태 코드: ${response.statusCode}");
        print("[DeleteRoom] -> 응답 본문: ${response.data}");

        if (response.statusCode == 200) {
          setState(() {
            previews.remove(roomId);
          });
          return true;
        }
      } catch (e) {
        print('삭제 실패: $e');
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Provider.of<AuthProvider>(context).isLoggedIn;
    final sorted =
        previews.entries.toList()
          ..sort((a, b) => b.value.time.compareTo(a.value.time));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPreviewsFromServer,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final msg = sorted[index].value;
                final preview =
                    msg.text.length > 35
                        ? '${msg.text.substring(0, 35)}...'
                        : msg.text;
                final date = msg.date;
                final time = msg.time;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Dismissible(
                    key: ValueKey(msg.roomId),
                    direction: DismissDirection.endToStart,
                    background: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    confirmDismiss: (_) => deleteRoom(msg.roomId),
                    child: InkWell(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(roomId: msg.roomId),
                            ),
                          ),
                      child: Container(
                        height: 77,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    preview,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$date   -   $time',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/history');
          } else if (index == 2) {
            if (isLoggedIn) {
              Navigator.pushNamed(context, '/mypage');
            } else {
              Navigator.pushNamed(context, '/login');
            }
          }
        },
      ),
    );
  }
}
