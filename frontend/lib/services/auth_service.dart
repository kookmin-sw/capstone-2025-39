import 'dart:convert';
import 'package:frontend/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://223.130.152.181:8080/api/users';

  static Future<Map<String, dynamic>> safePost(
    Uri url,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      try {
        // JSON 응답인지 확인
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.contains('application/json')) {
          return jsonDecode(response.body);
        } else {
          // JSON 아님 → 단순 메시지를 JSON으로 감싸서 반환
          return {'success': true, 'message': response.body};
        }
      } catch (e) {
        throw Exception('응답 파싱 오류: $e\n본문: ${response.body}');
      }
    } else {
      throw Exception('서버 오류: ${response.statusCode}\n본문: ${response.body}');
    }
  }

  /// 일반 로그인
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$_baseUrl/login');
    final response = await safePost(url, {
      'email': email,
      'password': password,
    });

    final token = response['accessToken'];
    if (token != null) {
      await SecureStorageService().saveToken(token);
    }

    return response;
  }

  // 일반 로그아웃
  static Future<void> logout() async {
    await SecureStorageService().deleteToken();
  }

  /// 일반 회원가입
  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final url = Uri.parse('$_baseUrl/signup');
    return await safePost(url, {
      'email': email,
      'password': password,
      'name': name,
    });
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
