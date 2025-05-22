import 'package:dio/dio.dart';

class LikeService {
  static final Dio _dio = Dio();
  static const String _baseUrl = 'http://15.165.95.8:8080';

  // 좋아요 상태 조회
  static Future<bool> fetchLikeStatus(String placeName, String token) async {
    try {
      final res = await _dio.get(
        '$_baseUrl/api/likes/status?placeName=${Uri.encodeComponent(placeName)}',
        options: Options(headers: {'Authorization': token}),
      );
      if (res.statusCode == 200 && res.data is Map) {
        return res.data['likedByUser'] == true;
      }
    } catch (e) {
      print('[LikeService] 상태 조회 실패: $e');
    }
    return false;
  }

  /// 좋아요 등록 또는 삭제 (toggle 방식)
  static Future<bool> toggleLike({
    required String placeName,
    required String token,
    required bool shouldLike,
  }) async {
    try {
      if (!shouldLike) {
        final res = await _dio.delete(
          '$_baseUrl/api/likes?placeName=${Uri.encodeComponent(placeName)}',
          options: Options(headers: {'Authorization': token}),
        );
        final success = res.statusCode == 200;
        print('[LikeService] 좋아요 삭제 응답: ${res.statusCode}, ${res.data}');
        return success ? false : shouldLike;
      } else {
        final res = await _dio.post(
          '$_baseUrl/api/likes',
          data: {'placeName': placeName},
          options: Options(
            headers: {
              'Authorization': token,
              'Content-Type': 'application/json',
            },
          ),
        );
        final success = res.statusCode == 200;
        print('[LikeService] 좋아요 등록 응답: ${res.statusCode}, ${res.data}');
        return success ? true : !shouldLike;
      }
    } catch (e) {
      print('[LikeService] 좋아요 토글 실패: $e');
      return shouldLike; // 실패 시 이전 상태 유지
    }
  }
}
