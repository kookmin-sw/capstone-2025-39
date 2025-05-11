import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatBotService {
  final String springBootUrl = 'http://223.130.152.181:8080/api/chat/ask';
  // final String springBootUrl = 'http://22.130.152.181:8080/api/chat/ask'; // 가짜

  Future<Map<String, dynamic>> getReply(
    String input, {
    required int roomId,
    String? token,
    double? lat,
    double? lng,
  }) async {
    try {
      final now = DateTime.now();

      // 요청 바디 구성
      Map<String, dynamic> requestBody = {
        "text": input,
        "time": DateFormat('HH:mm').format(now),
        "date": DateFormat('yyyy-MM-dd').format(now),
        "lat": lat ?? 0.0,
        "lng": lng ?? 0.0,
        "roomId": roomId, // 전달받은 roomId 사용
      };

      // 디버깅 로그
      print("-> 요청 URL: $springBootUrl");
      print("-> JWT 토큰: ${token ?? '없음'}");
      print("-> 요청 바디: ${jsonEncode(requestBody)}\n");

      // POST 요청
      final response = await http.post(
        Uri.parse(springBootUrl),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode(requestBody),
      );

      print("-> 응답 상태 코드: ${response.statusCode}");
      print("-> 응답 본문: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes); // 한글 깨짐 방지
        final data = jsonDecode(decoded);
        final reply = data['response'];
        final lat = data['lat'];
        final lng = data['lng'];
        print("-> 챗봇 응답(디코드): $data");

        if (lat is num && lng is num) {
          // reply["stores"] 는 가게 이름  37.605943, 127.011035
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
