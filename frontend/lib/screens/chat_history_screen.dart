import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import 'chat_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:frontend/providers/auth_provider.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final box = Hive.box<ChatMessage>('chatBox');
  Map<int, ChatMessage> previews = {};

  @override
  void initState() {
    super.initState();
    _loadPreviews();
  }

  // hive 저장 내용 로드
  void _loadPreviews() {
    previews.clear();
    for (var msg in box.values) {
      if (!previews.containsKey(msg.roomId)) {
        previews[msg.roomId] = msg;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn =
        Provider.of<AuthProvider>(context).isLoggedIn; // 로그인 상태 확인
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
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text('기록 삭제'),
                      content: const Text('모든 채팅 기록을 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            box.clear();
                            setState(() {
                              previews.clear();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
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
                  child: Stack(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: const Text('삭제 확인'),
                                    content: const Text('이 채팅 기록을 삭제하시겠습니까?'),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text('삭제'),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirmed ?? false) {
                              final keysToDelete =
                                  box.keys.where((key) {
                                    final m = box.get(key);
                                    return m is ChatMessage &&
                                        m.roomId == msg.roomId;
                                  }).toList();

                              box.deleteAll(keysToDelete);
                              setState(() {
                                previews.remove(msg.roomId);
                              });
                            }
                          },
                          // 삭제 버튼 영역
                          child: Container(
                            height: 75,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // 카드 위로 슬라이드
                      Slidable(
                        key: ValueKey(msg.roomId),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.2,
                          dismissible: null, // 슬라이드로 삭제 안함 (버튼만 사용)
                          children: [],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Material(
                            color: const Color(0xFFFAFAFA),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ChatScreen(roomId: msg.roomId),
                                  ),
                                );
                              },
                              child: Container(
                                height: 77,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                        ),
                      ),
                    ],
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
            // 홈
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            // TO DO: 채팅 기록 화면
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatHistoryScreen()),
            );
          } else if (index == 2) {
            // 내 계정 or 로그인 화면으로 이동
            if (isLoggedIn) {
              Navigator.pushNamed(context, '/mypage');
            } else {
              // 로그인 화면으로 이동
              Navigator.pushNamed(context, '/login');
            }
          }
        },
      ),
    );
  }
}
