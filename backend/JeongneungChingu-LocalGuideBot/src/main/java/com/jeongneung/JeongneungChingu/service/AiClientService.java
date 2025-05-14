package com.jeongneung.JeongneungChingu.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;

import java.util.HashMap;
import java.util.Map;

@Service
public class AiClientService {

    private final RestTemplate restTemplate = new RestTemplate();
    private final String FLASK_API_URL = "http://192.168.56.1:5000/chat"; // Flask 서버 주소

    public String queryAiServer(String message) {
        Map<String, String> request = new HashMap<>();
        request.put("message", message);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, String>> entity = new HttpEntity<>(request, headers);

        try {
            ResponseEntity<String> response = restTemplate.postForEntity(FLASK_API_URL, entity, String.class);

            // 🎯 응답 본문을 JSON으로 파싱
            ObjectMapper mapper = new ObjectMapper();
            Map<String, String> parsed = mapper.readValue(response.getBody(), Map.class);

            // ✅ 실제 응답 메시지 반환
            return parsed.get("response");

        } catch (Exception e) {
            e.printStackTrace();
            return "❌ AI 서버와의 통신 실패: " + e.getMessage();
        }
    }
}
