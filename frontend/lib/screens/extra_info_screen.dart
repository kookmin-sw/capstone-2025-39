import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExtraInfoScreen extends StatefulWidget {
  final String email;

  const ExtraInfoScreen({super.key, required this.email});

  @override
  State<ExtraInfoScreen> createState() => _ExtraInfoScreenState();
}

class _ExtraInfoScreenState extends State<ExtraInfoScreen> {
  final TextEditingController nicknameController = TextEditingController();
  bool agreedToTerms = false;

  Future<void> _submitExtraInfo() async {
    final nickname = nicknameController.text.trim();

    if (nickname.isEmpty || !agreedToTerms) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('닉네임을 입력하고 약관에 동의해주세요.')));
      return;
    }

    final url = Uri.parse('http://211.188.53.1:8080/users/register-extra');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': widget.email,
        'nickname': nickname,
        'agreedToTerms': agreedToTerms,
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('추가 정보 입력')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('닉네임'),
            const SizedBox(height: 8),
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(
                hintText: '닉네임을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Checkbox(
                  value: agreedToTerms,
                  onChanged: (value) {
                    setState(() {
                      agreedToTerms = value ?? false;
                    });
                  },
                ),
                const Text('이용약관에 동의합니다.'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitExtraInfo,
                child: const Text('회원가입 완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
