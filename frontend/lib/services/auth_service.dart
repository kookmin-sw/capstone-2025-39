import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://211.188.53.1:8080/api/users';

  /// 일반 로그인
  static Future<Map<String, dynamic>> login(
    String userId,
    String password,
  ) async {
    final url = Uri.parse('$_baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('로그인 실패: ${response.body}');
    }
  }

  /// 일반 회원가입
  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final url = Uri.parse('$_baseUrl/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? '회원가입 실패');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  /// 구글 로그인
  static Future<Map<String, dynamic>> googleLogin({
    required String idToken,
    required String accessToken,
  }) async {
    final url = Uri.parse('$_baseUrl/oauth');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'provider': 'google',
        'idToken': idToken,
        'accessToken': accessToken,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('구글 로그인 실패: ${response.body}');
    }
  }
}
