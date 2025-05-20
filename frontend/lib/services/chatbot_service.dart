import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class ChatBotService {
  final String springBootUrl = 'http://15.165.95.8:8080/api/chat/ask';
  final Dio dio = Dio();

  Future<Map<String, dynamic>> getReply(
    String input, {
    required int roomId,
    String? token,
    double? lat,
    double? lng,
  }) async {
    try {
      final now = DateTime.now();

      Map<String, dynamic> requestBody = {
        "text": input,
        "time": DateFormat('HH:mm').format(now),
        "date": DateFormat('yyyy-MM-dd').format(now),
        "lat": lat,
        "lng": lng,
        "roomId": roomId,
      };

      print("-> 요청 URL: $springBootUrl");
      print("-> JWT 토큰: ${token ?? '없음'}");
      print("-> 요청 바디: $requestBody\n");

      final response = await dio.post(
        springBootUrl,
        data: requestBody,
        options: Options(
          headers: {
            "Content-Type": "application/json; charset=UTF-8",
            if (token != null) "Authorization": "Bearer $token",
          },
        ),
      );

      print("-> 응답 상태 코드: ${response.statusCode}");
      print("-> 응답 본문: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;
        final reply = data['text'];
        final double? lat =
            (data['lat'] is num) ? (data['lat'] as num).toDouble() : null;
        final double? lng =
            (data['lng'] is num) ? (data['lng'] as num).toDouble() : null;

        print("-> 챗봇 응답(디코드): $data");

        if (lat != null && lng != null) {
          return {'reply': reply, 'lat': lat, 'lng': lng};
        } else {
          return {'reply': reply};
        }
      } else {
        return {'reply': "챗봇 응답 실패: 다시 시도해주세요 (${response.statusCode})"};
      }
    } on DioException catch (dioError) {
      print("[Dio 예외 발생] ${dioError.message}");
      return {'reply': "네트워크 오류 또는 서버 오류: ${dioError.message}"};
    } catch (e) {
      print("[알 수 없는 예외] $e");
      return {'reply': "알 수 없는 오류: $e"};
    }
  }
}
