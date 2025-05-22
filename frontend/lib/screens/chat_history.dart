import 'package:flutter/material.dart';
import 'package:frontend/models/chat_message.dart';
import 'package:frontend/screens/load_chat.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class ChatHistory extends StatefulWidget {
  const ChatHistory({super.key});

  @override
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
  Map<int, ChatMessage> chatPreviews = {};
  final Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  // 전체 채팅 기록을 서버에서 가져오는 메서드
  Future<void> _loadChatHistory() async {
    final auth = context.read<AuthProvider>();
    final url = 'http://15.165.95.8:8080/api/chat/rooms';

    try {
      final response = await dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        final Map<int, ChatMessage> latest = {};

        for (var item in data) {
          final msg = ChatMessage(
            text: item['text'],
            isUser: item['isUser'],
            time: item['time'],
            date: item['date'],
            lat: item['lat'],
            lng: item['lng'],
            roomId: item['roomId'],
            placeName: item['placeName'],
          );

          if (!latest.containsKey(msg.roomId) ||
              msg.time.compareTo(latest[msg.roomId]!.time) > 0) {
            latest[msg.roomId] = msg;
          }
        }

        setState(() {
          chatPreviews = latest;
        });
      }
    } catch (e) {
      print('채팅 기록 불러오기 실패: $e');
    }
  }

  // 채팅방 삭제 메서드
  Future<bool> _deleteRoom(int roomId) async {
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
      final url = 'http://15.165.95.8:8080/api/chat/delete/$roomId';

      try {
        final response = await dio.delete(
          url,
          options: Options(headers: {'Authorization': 'Bearer ${auth.token}'}),
        );

        if (response.statusCode == 200) {
          setState(() {
            chatPreviews.remove(roomId);
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
    // list 정렬 규칙 : date, time 합쳐서 내림차순 정렬
    final sorted =
        chatPreviews.entries.toList()..sort((a, b) {
          final format = DateFormat('yyyy.MM.dd EEEE a hh:mm', 'ko');
          final aDateTime = format.parse("${a.value.date} ${a.value.time}");
          final bDateTime = format.parse("${b.value.date} ${b.value.time}");
          return bDateTime.compareTo(aDateTime);
        });

    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final msg = sorted[index].value;
        final preview =
            msg.text.length > 35 ? '${msg.text.substring(0, 35)}...' : msg.text;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            confirmDismiss: (_) => _deleteRoom(msg.roomId),
            child: InkWell(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoadChat(roomId: msg.roomId),
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
                            '${msg.date}   -   ${msg.time}',
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
    );
  }
}
