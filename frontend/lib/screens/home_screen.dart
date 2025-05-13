import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:frontend/screens/chat_screen.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/utils/getNextRoomId.dart';
import 'package:frontend/screens/chat_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // 로그인 상태 전달받음

  @override
  Widget build(BuildContext context) {
    final isLoggedIn =
        Provider.of<AuthProvider>(context).isLoggedIn; // 로그인 상태 확인
    return Scaffold(
      backgroundColor: const Color(0xFF5B7553), // 초록 배경
      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            // 홈
          } else if (index == 1) {
            // 채팅 기록 화면
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
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              const Text(
                'CHINGU',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFE5E6E1),
                  fontFamily: 'Nunito',
                  fontSize: 39,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 241,
                child: Text(
                  '마을 가이드\n정릉친구',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFE5E6E1),
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 60),
              // 말풍선 아이콘
              Image.asset(
                'assets/images/home_img.png',
                width: 278,
                height: 278,
              ),
              const SizedBox(height: 60),

              // 대화 시작 버튼
              ElevatedButton(
                onPressed: () async {
                  final int newRoomId = await getNextRoomId(); // 자동 roomId 생성
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(roomId: newRoomId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF90A891),
                  minimumSize: const Size(361, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '대화 시작하기',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
