import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import '../widgets/info_text_field.dart';
import '../widgets/custom_password_field.dart';
import '../widgets/custom_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();

  String? errorMessage;
  bool isLoading = false;

  void validateAndSignUp() async {
    if (passwordController.text != passwordConfirmController.text) {
      setState(() {
        errorMessage = "비밀번호가 일치하지 않습니다.";
      });
      return;
    }

    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      final response = await AuthService.signup(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
      );

      if (response['success']) {
        setState(() {
          isLoading = false;
        });
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          errorMessage = response['message'] ?? "회원가입에 실패했습니다.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목: 회원 가입
              const SizedBox(height: 8),
              const Text(
                "회원 가입",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 96),
              // 이름
              const Text("이름"),
              const SizedBox(height: 8),
              InfoTextField(hintText: "이름", controller: nameController),

              // 이메일
              const SizedBox(height: 24),
              const Text("이메일 주소"),
              const SizedBox(height: 8),
              InfoTextField(
                hintText: "Email",
                icon: Icons.email,
                controller: emailController,
              ),

              // 비밀번호
              const SizedBox(height: 24),
              const Text("비밀번호"),
              const SizedBox(height: 8),
              CustomPasswordField(controller: passwordController),

              // 비밀번호 확인
              const SizedBox(height: 24),
              const Text("비밀번호 확인"),
              const SizedBox(height: 8),
              CustomPasswordField(controller: passwordConfirmController),

              // 에러 메시지
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ],

              // 등록하기 버튼
              const SizedBox(height: 32),
              Center(
                child:
                    isLoading
                        ? const CircularProgressIndicator(
                          color: Color(0xFF54A777),
                        )
                        : SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: "등록하기",
                            onPressed: validateAndSignUp,
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
