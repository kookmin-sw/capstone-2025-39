import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF5B7553), // 초록색 계열로 변경 가능
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500, // 선택된 항목의 텍스트 스타일
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500, // 선택되지 않은 항목의 텍스트 스타일
      ),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅 기록'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 계정'),
      ],
    );
  }
}
