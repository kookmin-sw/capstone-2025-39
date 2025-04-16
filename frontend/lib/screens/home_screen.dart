import 'package:flutter/material.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:frontend/screens/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          // 페이지 이동 로직 작성 하기!!
          print("탭 $index 클릭됨");
        },
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 대화 시작하기 버튼
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B7553), // 초록 계열
                    minimumSize: const Size(350, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '대화 시작하기',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 40),

                // 앱 설명 버튼
                _buildSubButton('정릉 동네 정보, 한눈에 보기'),
                const SizedBox(height: 16),
                _buildSubButton('마을 소식 알아보기'),
                const SizedBox(height: 16),
                _buildSubButton('음성인식으로 쉽게 대화해요'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 서브 버튼 위젯 분류
  Widget _buildSubButton(String text) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }
}
