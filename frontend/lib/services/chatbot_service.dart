import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class ChatBotService {
  final String springBootUrl = 'http://223.130.152.181:8080/api/chat/ask';
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
        "lat": lat ?? 0.0,
        "lng": lng ?? 0.0,
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
        final reply = data['response'];
        final lat = data['lat'];
        final lng = data['lng'];
        print("-> 챗봇 응답(디코드): $data");

        if (lat is num && lng is num) {
          return {'reply': reply, 'lat': lat, 'lng': lng};
        } else {
          return {'reply': reply, 'lat': 37.605943, 'lng': 127.011035};
        }
      } else {
        return {'reply': "챗봇 응답 실패: 다시 시도해주세요 (${response.statusCode})"};
      }
    } catch (e) {
      return {'reply': "요청 실패: $e", 'lat': 37.610827, 'lng': 126.996350};
    }
  }
}
