import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:frontend/screens/chat_screen.dart';
import 'package:frontend/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // 로그인 상태 전달받음

  @override
  Widget build(BuildContext context) {
    final isLoggedIn =
        Provider.of<AuthProvider>(context).isLoggedIn; // 로그인 상태 확인
    return Scaffold(
      backgroundColor: const Color(0xFF5B7553), // 초록 배경
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            // 홈
          } else if (index == 1) {
            // TO DO: 채팅 기록 화면
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
              // 말풍선 아이콘
              Image.asset(
                'assets/images/home_icon.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 24),

              // 설명 텍스트
              const Text(
                'Start chatting now.\nYou can ask me anything.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // 대화 시작 버튼
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(250, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '대화 시작하기',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5B7553),
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
