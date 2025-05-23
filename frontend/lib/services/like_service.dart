import 'package:dio/dio.dart';

class LikeService {
  static final Dio _dio = Dio();
  static const String _baseUrl = 'http://15.165.95.8:8080';

  // 좋아요 상태 조회
  static Future<bool> fetchLikeStatus(String placeName, String token) async {
    try {
      final encodedPlaceName = Uri.encodeComponent(placeName);
      final url = '$_baseUrl/api/likes/status?placeName=$encodedPlaceName';
      print('[LikeService] 상태 조회 요청 URL: $url');

      final res = await _dio.get(
        url,
        options: Options(headers: {'Authorization': token}),
      );

      print('[LikeService] 상태 조회 응답: ${res.statusCode}, ${res.data}');

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
    final encodedPlaceName = Uri.encodeComponent(placeName);

    try {
      if (!shouldLike) {
        // 좋아요 취소!!
        final url = '$_baseUrl/api/likes?placeName=$encodedPlaceName';
        print('[LikeService] 좋아요 삭제 요청');
        print('→ placeName: $placeName');
        print('→ shouldLike: $shouldLike');
        print('→ 요청 URL: $url');

        final res = await _dio.delete(
          url,
          options: Options(headers: {'Authorization': token}),
        );
        print('[LikeService] 좋아요 삭제 응답: ${res.statusCode}, ${res.data}');
        final success = res.statusCode == 200;
        return success ? false : shouldLike;
      } else {
        // 좋아요 등록!!
        final url = '$_baseUrl/api/likes';
        final requestBody = {'placeName': placeName};
        print('[LikeService] 좋아요 등록 요청');
        print('→ placeName: $placeName');
        print('→ shouldLike: $shouldLike');
        print('→ 요청 바디: $requestBody');

        final res = await _dio.post(
          url,
          data: requestBody,
          options: Options(
            headers: {
              'Authorization': token,
              'Content-Type': 'application/json',
            },
          ),
        );

        print('[LikeService] 좋아요 등록 응답: ${res.statusCode}, ${res.data}');
        final success = res.statusCode == 200;
        return success ? true : !shouldLike;
      }
    } catch (e) {
      print('[LikeService] 좋아요 토글 실패: $e');
      return shouldLike; // 실패 시 이전 상태 유지
    }
  }
}
