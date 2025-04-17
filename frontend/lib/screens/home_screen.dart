import 'package:flutter/material.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:frontend/screens/chat_screen.dart';
import 'package:frontend/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B7553), // 초록 배경
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
<<<<<<< HEAD
<<<<<<< HEAD
          if (index == 0) {
            // 홈
          } else if (index == 1) {
            // TODO: 채팅 기록 화면
=======
          // 페이지 이동 로직
=======
>>>>>>> dea1ce2 (homescreen 수정)
          if (index == 0) {
            // 홈
          } else if (index == 1) {
<<<<<<< HEAD
            // TODO : 채팅 기록 구현!!
>>>>>>> 1213d29 (로그인 ui수정)
=======
            // TODO: 채팅 기록 화면
>>>>>>> dea1ce2 (homescreen 수정)
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
          }
<<<<<<< HEAD
<<<<<<< HEAD
=======

>>>>>>> 1213d29 (로그인 ui수정)
=======
>>>>>>> dea1ce2 (homescreen 수정)
        },
      ),
      body: SafeArea(
        child: Center(
          child: Column(
<<<<<<< HEAD
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 말풍선 아이콘
              Image.asset(
                'assets/images/home_icon.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 24),

=======
            children: [
              SizedBox(height: 180),
              // 말풍선 아이콘
              Image.asset(
                'assets/images/home_icon.png', // homescreen_icon
                width: 199.06,
                height: 155.61,
              ),
              const SizedBox(height: 79),
>>>>>>> dea1ce2 (homescreen 수정)
              // 설명 텍스트
              const Text(
                'Start chatting now.\nYou can ask me anything.',
                textAlign: TextAlign.center,
                style: TextStyle(
<<<<<<< HEAD
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
=======
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w200, // Thin
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
>>>>>>> dea1ce2 (homescreen 수정)

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
<<<<<<< HEAD
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
=======
                  minimumSize: const Size(342, 59),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF3D4D3D),
                ),
                child: const Text(
                  '대화 시작하기',
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF5E8360),
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600, // SemiBold
                  ),
                ),
>>>>>>> dea1ce2 (homescreen 수정)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
