import 'package:dio/dio.dart';
import 'package:frontend/providers/auth_provider.dart';

class AuthService {
  static const String _baseUrl = 'http://223.130.152.181:8080/api/users';
  static final Dio dio = Dio();

  static Future<Map<String, dynamic>> safePost(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await dio.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: body,
      );

      if (response.statusCode == 200) {
        if (response.headers['content-type']?.any(
              (e) => e.contains('application/json'),
            ) ??
            false) {
          return response.data;
        } else {
          return {'success': true, 'message': response.data.toString()};
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}\n본문: ${response.data}');
      }
    } catch (e) {
      throw Exception('응답 파싱 오류: $e');
    }
  }

  /// 일반 로그인
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = '$_baseUrl/login';
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
    final url = '$_baseUrl/signup';
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
    final url = '$_baseUrl/oauth';
    try {
      final response = await dio.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'provider': 'google',
          'idToken': idToken,
          'accessToken': accessToken,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('구글 로그인 실패: ${response.data}');
      }
    } catch (e) {
      throw Exception('구글 로그인 예외: $e');
    }
  }
}
