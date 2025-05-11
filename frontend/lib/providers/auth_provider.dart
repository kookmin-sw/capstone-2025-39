import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _token;
  int? _userId;

  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  int? get userId => _userId;

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
    _userId = userId;
    _isLoggedIn = true;
    await SecureStorageService().saveToken(token);
    notifyListeners();
  }

  // 로그아웃 시 호출
  Future<void> logOut() async {
    _token = null;
    _userId = null;
    _isLoggedIn = false;
    await SecureStorageService().deleteToken();
    await SecureStorageService().deleteUserId();
    notifyListeners();
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
  Future<void> saveUserId(int userId) async =>
      await _storage.write(key: 'userId', value: userId.toString());

  Future<int?> getUserId() async {
    final id = await _storage.read(key: 'userId');
    return id != null ? int.tryParse(id) : null;
  }

  Future<void> deleteUserId() async => await _storage.delete(key: 'userId');
}
