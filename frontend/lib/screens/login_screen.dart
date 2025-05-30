import 'package:flutter/material.dart';
import 'package:frontend/screens/sign_up_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:frontend/widgets/info_text_field.dart';
import 'package:frontend/widgets/custom_password_field.dart';
import 'package:frontend/widgets/custom_button.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/bottom_nav.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  // 구글 로그인
  Future<void> _handleGoogleLogin() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        // 사용자가 로그인 취소
        return;
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      final responseData = await AuthService.googleLogin(
        idToken: idToken!,
        accessToken: accessToken!,
      );

      final isNewUser = responseData['isNewUser'] == true;

      // 첫 사용자
      if (isNewUser) {
        // 회원원 가입 성공 시
        Provider.of<AuthProvider>(
          context,
          listen: false,
        ).logIn(accessToken); // 로그인 true로 상태 변경
        // 회원가입 성공 메세지 Dialog
        showDialog(
          context: context,
          barrierDismissible: false, // 팝업 바깥 터치해도 안 닫히게
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '회원가입 성공!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF54A777), // 연한 초록
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Please wait...'),
                    const SizedBox(height: 8),
                    const Text('마이페이지로 이동합니다.'),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(color: Color(0xFF54A777)),
                  ],
                ),
              ),
            );
          },
        );
        // 2초 기다렸다가 마이페이지 이동
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;
        Navigator.pop(context); // Dialog 먼저 닫는다.
        Navigator.pushReplacementNamed(context, '/mypage'); // 마이페이지로 이동
        print('Google 로그인 성공: ${responseData['message']}');
      } else {
        // 기존 사용자 -> 로그인 성공 화면으로 이동
        Provider.of<AuthProvider>(
          context,
          listen: false,
        ).logIn(accessToken); // 로그인 true로 상태 변경
        Navigator.pushReplacementNamed(context, '/mypage');
      }
    } catch (e) {
      // 로그인 실패
      if (!mounted) return;
      print('Google 로그인 중 오류 발생: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google 로그인 중 오류가 발생했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn =
        Provider.of<AuthProvider>(context).isLoggedIn; // 로그인 상태 확인
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Text("이메일 주소"),
              const SizedBox(height: 8),
              InfoTextField(
                hintText: 'Email',
                icon: Icons.email,
                controller: emailController,
              ),
              const SizedBox(height: 24),
              const Text("비밀번호"),
              const SizedBox(height: 8),
              CustomPasswordField(controller: passwordController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(value: false, onChanged: (_) {}),
                  const Text("Remember me"),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forgot password?",
                    style: TextStyle(color: Colors.indigo),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "회원가입",
                      style: TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const Center(child: Text("or continue with")),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 구글 로그인 동작
                  SizedBox(
                    width: 180,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _handleGoogleLogin,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: Image.asset(
                        'assets/images/google.png',
                        width: 20,
                        height: 20,
                      ),

                      label: const Text(
                        'Google',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 2),
                  // Apple Button
                  SizedBox(
                    width: 180,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // 애플 로그인 동작
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(
                        Icons.apple,
                        size: 24,
                        color: Colors.black,
                      ),
                      label: const Text(
                        'Apple',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              // 일반 로그인 버튼
              const SizedBox(height: 24),
              Center(
                child: CustomButton(
                  text: "로그인",
                  onPressed: () async {
                    final userId = emailController.text.trim();
                    final password = passwordController.text;
                    try {
                      final result = await AuthService.login(userId, password);
                      final token = result['accessToken'];

                      // 로그인 상태 및 토큰 저장
                      print(('로그인 성공 '));
                      Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).logIn(token); // 로그인 true로 상태 변경
                      Navigator.pushReplacementNamed(context, '/mypage');
                    } catch (e) {
                      if (!mounted) return;
                      print('오류 발생: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이메일 또는 비밀번호가 잘못되었습니다.')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            // 홈
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            // TO DO: 채팅 기록 화면
            Navigator.pushNamed(context, '/history');
          } else if (index == 2) {
            // 내 계정 or 로그인 화면으로 이동 (로그인 상태에 따라)
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
