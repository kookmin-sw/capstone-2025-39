import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatBotService {
  /* Spring Boot 서버의 주소를 가져온다.
     'http://<your-spring-url>:<port>/chat';
     <your-spring-url> : 서버 ip or domain
     <port> : Spring Boot 서버의 포트 (예 8080)
     /chat : 요청을 보낼 API 경로 

     임시로 서버 로컬에서 돌리므로 http://10.0.2.2:8080/chat 형태
  */
  final String springBootUrl = '';

  Future<String> getReply(String input) async {
    try {
      //요청 바디 구성
      Map<String, String> requestBody = {"message": input};

      //POST 요청
      final response = await http.post(
        Uri.parse(springBootUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      //응답 처리
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['response'] ?? "응답이 없습니다.";
      } else {
        return "오류 발생했습니다: ${response.statusCode}";
      }
    } catch (e) {
      return "요청 실패했습니다: $e";
    }
  } //async
}
