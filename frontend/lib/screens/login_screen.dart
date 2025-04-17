import 'package:flutter/material.dart';
<<<<<<< HEAD
<<<<<<< HEAD
import 'package:google_sign_in/google_sign_in.dart';
import 'package:frontend/screens/extra_info_screen.dart';
=======
>>>>>>> 1213d29 (로그인 ui수정)
=======
import 'package:google_sign_in/google_sign_in.dart';
import 'package:frontend/screens/extra_info_screen.dart';
>>>>>>> ff5823f (google sign-in)
import '../widgets/info_text_field.dart';
import '../widgets/custom_password_field.dart';
import '../widgets/custom_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> ff5823f (google sign-in)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
<<<<<<< HEAD
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  Future<void> _handleGoogleLogin() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return; // 사용자가 로그인 취소함

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      final url = Uri.parse('http://211.188.53.1:8080/users/oauth');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': 'google',
          'idToken': idToken,
          'accessToken': accessToken,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final isNewUser = responseData['isNewUser'] == true;

        // 첫 사용자 -> 추가 정보 입력 폼
        if (isNewUser) {
          final email = responseData['email'];
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ExtraInfoScreen(email: email)),
          );
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }

        print('Google 로그인 성공: ${responseData['message']}');
        // 예: Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('Google 로그인 실패: ${response.body}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Google 로그인에 실패했습니다.')));
      }
    } catch (e) {
      if (!mounted) return;
      print('Google 로그인 중 오류 발생: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google 로그인 중 오류가 발생했습니다.')));
    }
  }
=======
class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});
>>>>>>> 1213d29 (로그인 ui수정)
=======
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  Future<void> _handleGoogleLogin() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return; // 사용자가 로그인 취소함

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      final url = Uri.parse('http://211.188.53.1:8080/users/oauth');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': 'google',
          'idToken': idToken,
          'accessToken': accessToken,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final isNewUser = responseData['isNewUser'] == true;

        // 첫 사용자 -> 추가 정보 입력 폼
        if (isNewUser) {
          final email = responseData['email'];
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ExtraInfoScreen(email: email)),
          );
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }

        print('Google 로그인 성공: ${responseData['message']}');
        // 예: Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('Google 로그인 실패: ${response.body}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Google 로그인에 실패했습니다.')));
      }
    } catch (e) {
      if (!mounted) return;
      print('Google 로그인 중 오류 발생: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google 로그인 중 오류가 발생했습니다.')));
    }
  }
>>>>>>> ff5823f (google sign-in)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
<<<<<<< HEAD
<<<<<<< HEAD
                  Navigator.of(context).pop();
=======
                  Navigator.of(context).pop(); // ← 여기서 뒤로가기
>>>>>>> 1213d29 (로그인 ui수정)
=======
                  Navigator.of(context).pop();
>>>>>>> ff5823f (google sign-in)
                },
              ),
            ),
          ],
        ),
      ),
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
<<<<<<< HEAD
<<<<<<< HEAD
                icon: Icons.email,
=======
                icon: Icons.email_outlined,
>>>>>>> 1213d29 (로그인 ui수정)
=======
                icon: Icons.email,
>>>>>>> ff5823f (google sign-in)
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
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "Sign up",
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
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> ff5823f (google sign-in)
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
<<<<<<< HEAD
=======
                children: const [
                  CircleAvatar(child: Icon(Icons.g_mobiledata, size: 32)),
                  CircleAvatar(child: Icon(Icons.apple, size: 28)),
>>>>>>> 1213d29 (로그인 ui수정)
=======
>>>>>>> ff5823f (google sign-in)
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: CustomButton(
                  text: "로그인",
                  onPressed: () async {
                    final userId = emailController.text.trim();
                    final password = passwordController.text;

                    final url = Uri.parse(
                      'http://211.188.53.1:8080/users/login',
                    );

                    try {
                      final response = await http.post(
                        url,
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'userId': userId,
                          'password': password,
                        }),
                      );

<<<<<<< HEAD
<<<<<<< HEAD
                      if (!mounted) return;

                      if (response.statusCode == 200) {
                        final responseData = jsonDecode(response.body);
                        print('로그인 성공: ${responseData['message']}');
=======
                      if (response.statusCode == 200) {
                        final responseData = jsonDecode(response.body);
                        print('로그인 성공: ${responseData['message']}');

                        // 예: Navigator.pushReplacement(...) 로 메인 화면으로 이동
                        // 또는 토큰 저장, 상태 관리 등
>>>>>>> 1213d29 (로그인 ui수정)
=======
                      if (!mounted) return;

                      if (response.statusCode == 200) {
                        final responseData = jsonDecode(response.body);
                        print('로그인 성공: ${responseData['message']}');
>>>>>>> ff5823f (google sign-in)
                      } else {
                        print('로그인 실패: ${response.body}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('이메일 또는 비밀번호가 잘못되었습니다.'),
                          ),
                        );
                      }
                    } catch (e) {
<<<<<<< HEAD
<<<<<<< HEAD
                      if (!mounted) return;
=======
>>>>>>> 1213d29 (로그인 ui수정)
=======
                      if (!mounted) return;
>>>>>>> ff5823f (google sign-in)
                      print('오류 발생: $e');
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('서버 연결 오류')));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
