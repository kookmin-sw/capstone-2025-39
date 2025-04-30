import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        title: const Text(
          'Account',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w800, // Bold
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        // ListView : 마이페이지 본인 정보 표시 및 수정 버튼
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 24),
            ListTile(
              leading: const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.black,
              ),
              title: const Text(
                '안녕하세요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w800, // SemiBold
                  fontSize: 20,
                ),
              ),
              subtitle: const Text(
                'hello@.com',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const SizedBox(height: 18),

            // General
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    'General',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text(
                '개인 정보',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w800,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                '보안',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w800,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const SizedBox(height: 18),
            // About
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    'About',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text(
                'Help Center',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w800,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                'About ChatAI',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w800,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                '로그아웃',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onTap: () {
                Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).logOut(); // 로그아웃으로 상태 변경
                Navigator.pushReplacementNamed(
                  context,
                  '/login',
                ); // 로그인 화면 돌아가기
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/chat');
          }
        },
      ),
    );
  }
}
