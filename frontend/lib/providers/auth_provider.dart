import 'package:flutter/material.dart';

// 로그인 상태를 관리하는 Provider
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;

  // 외부에서 로그인 상태 읽을 수 있도록 제공 getter
  bool get isLoggedIn => _isLoggedIn;

  // 로그인 상태 true로 변경하는 메서드
  void logIn() {
    _isLoggedIn = true;
    notifyListeners(); // 상태 변경 알림
  }

  // 로그인 상태 false로 변경하는 메서드
  void logOut() {
    _isLoggedIn = false;
    notifyListeners(); // 상태 변경 알림
  }
}
