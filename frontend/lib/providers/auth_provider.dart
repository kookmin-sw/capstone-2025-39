import 'package:flutter/material.dart';
import 'package:frontend/services/secure_storage_service.dart';

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
