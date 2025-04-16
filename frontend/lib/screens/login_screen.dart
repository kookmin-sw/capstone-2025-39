import 'package:flutter/material.dart';
import '../widgets/info_text_field.dart';
import '../widgets/custom_password_field.dart';
import '../widgets/custom_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

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
                  Navigator.of(context).pop(); // ← 여기서 뒤로가기
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
                icon: Icons.email_outlined,
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
                children: const [
                  CircleAvatar(child: Icon(Icons.g_mobiledata, size: 32)),
                  CircleAvatar(child: Icon(Icons.apple, size: 28)),
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

                      if (response.statusCode == 200) {
                        final responseData = jsonDecode(response.body);
                        print('로그인 성공: ${responseData['message']}');

                        // 예: Navigator.pushReplacement(...) 로 메인 화면으로 이동
                        // 또는 토큰 저장, 상태 관리 등
                      } else {
                        print('로그인 실패: ${response.body}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('이메일 또는 비밀번호가 잘못되었습니다.'),
                          ),
                        );
                      }
                    } catch (e) {
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
