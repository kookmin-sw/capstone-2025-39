import 'package:flutter/material.dart';
import 'package:frontend/screens/chat_history.dart';
import 'package:frontend/screens/liked_history.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn =
        Provider.of<AuthProvider>(context).isLoggedIn; // 로그인 상태 확인
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // ← 왼쪽 정렬
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTabButton('채팅', 0),
                const SizedBox(width: 8),
                _buildTabButton('좋아요', 1),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child:
                _selectedTab == 0
                    ? const ChatHistory()
                    : const LikedHistoryScreen(),
          ),
        ],
      ),
      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            // 홈
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            // 채팅 기록 화면
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
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

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;

    return SizedBox(
      height: 36,
      child: TextButton(
        onPressed: () => setState(() => _selectedTab = index),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: isSelected ? Colors.black : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}
