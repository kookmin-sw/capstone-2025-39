// chat_map.dart 내에서 liked 상태를 전역으로 관리하기 위한 provider
import 'package:flutter/material.dart';

class LikeProvider with ChangeNotifier {
  final Map<String, bool> _likes = {};

  // placeName 별로 좋아요 상태를 관리
  bool getLike(String placeName) => _likes[placeName] ?? false;

  // Like 상태 설정
  void setLike(String placeName, bool liked) {
    _likes[placeName] = liked;
    notifyListeners();
  }

  // Like 현재 버튼 상태 관리
  void toggleLike(String placeName) {
    final current = _likes[placeName] ?? false;
    _likes[placeName] = !current;
    notifyListeners();
  }
}
