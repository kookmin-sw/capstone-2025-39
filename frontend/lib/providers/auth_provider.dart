import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _token;
  String? _userId;
  String? _name;

  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  String? get userId => _userId;
  String? get name => _name;

  // 앱 시작 시 토큰 불러오기
  Future<void> loadTokenFromStorage() async {
    final storedToken = await SecureStorageService().getToken();
    if (storedToken != null) {
      _token = storedToken;
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  // 로그인 시 호출
  Future<void> logIn(String token) async {
    _token = token;
    _isLoggedIn = true;
    await SecureStorageService().saveToken(token);
    notifyListeners();
  }

  // 로그아웃 시 호출
  Future<void> logOut() async {
    _token = null;
    _userId = null;
    _name = null;
    _isLoggedIn = false;
    await SecureStorageService().deleteToken();
    await SecureStorageService().deleteUserId();
    await SecureStorageService().deleteUserName();
    notifyListeners();
  }

  // 유저 정보 불러오기
  Future<void> getUserData() async {
    try {
      final data = await AuthService.getUserData();
      _userId = data['userId'];
      _name = data['name'];

      await SecureStorageService().saveUserId(_userId ?? '');
      await SecureStorageService().saveUserName(_name ?? '');

      notifyListeners();
    } catch (e) {
      print("유저 데이터 로드 실패: $e");
    }
  }
}

// Id 토큰 저장
class SecureStorageService {
  final _storage = FlutterSecureStorage();

  Future<void> saveToken(String token) async =>
      await _storage.write(key: 'token', value: token);

  Future<String?> getToken() async => await _storage.read(key: 'token');

  Future<void> deleteToken() async => await _storage.delete(key: 'token');

  // userId 저장 관련
  Future<void> saveUserId(String userId) async =>
      await _storage.write(key: 'userId', value: userId.toString());

  Future<String?> getUserId() async {
    final id = await _storage.read(key: 'userId');
    return id;
  }

  Future<void> deleteUserId() async => await _storage.delete(key: 'userId');

  // user data 관련
  Future<void> saveUserName(String name) async =>
      await _storage.write(key: 'name', value: name);

  Future<String?> getUserName() async => await _storage.read(key: 'name');

  Future<void> deleteUserName() async => await _storage.delete(key: 'name');
}
