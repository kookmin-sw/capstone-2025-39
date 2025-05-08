import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:frontend/models/chat_message.dart';
import 'chat_screen.dart';
import 'package:frontend/services/secure_storage_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:frontend/providers/auth_provider.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  Map<int, ChatMessage> previews = {};

  @override
  void initState() {
    super.initState();
    _loadPreviewsFromServer();
  }

  Future<void> _loadPreviewsFromServer() async {
    final auth = context.read<AuthProvider>();
    final url = Uri.parse('http://223.130.152.181:8080/api/chat/room');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${auth.token}'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      previews.clear();
      for (var item in data) {
        final msg = ChatMessage(
          text: item['text'],
          isUser: item['isUser'],
          time: item['time'],
          date: item['date'],
          lat: item['lat'],
          lng: item['lng'],
          roomId: item['roomId'],
        );
        previews[msg.roomId] = msg;
      }
      setState(() {});
    }
  }

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
      final url = Uri.parse(
        'http://223.130.152.181:8080/api/chat/room/$roomId',
      );

      final res = await http.delete(
        url,
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );

      if (res.statusCode == 200) {
        setState(() {
          previews.remove(roomId);
        });
        return true;
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
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) => deleteRoom(msg.roomId),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatHistoryScreen()),
            );
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
