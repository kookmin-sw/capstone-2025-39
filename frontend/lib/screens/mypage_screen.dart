import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});
  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  @override
  void initState() {
    super.initState();
    // MyPage 들어올 때 최신 유저 데이터 자동 로드
    Future.microtask(
      () => Provider.of<AuthProvider>(context, listen: false).getUserData(),
    );
  }

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
              // 유저 이름
              title: Text(
                Provider.of<AuthProvider>(context).name ?? '이름 없음',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w800, // SemiBold
                  fontSize: 20,
                ),
              ),
              // 유저 이메일
              subtitle: Text(
                Provider.of<AuthProvider>(context).userId ?? '아이디 없음',
                style: const TextStyle(
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
            ListTile(
              title: const Text(
                '회원 탈퇴',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.redAccent,
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
      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/history');
          }
        },
      ),
    );
  }
}
