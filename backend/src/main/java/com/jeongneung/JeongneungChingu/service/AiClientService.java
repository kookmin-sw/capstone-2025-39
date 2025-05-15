package com.jeongneung.JeongneungChingu.service;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import com.jeongneung.JeongneungChingu.domain.dto.AnswerDto;
import java.util.Map;

@Service
public class AiClientService {
    private final RestTemplate restTemplate;
    private static final String FLASK_API_URL = "http://223.130.152.181:5000/chat";

    public AiClientService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    /** 사용자 메시지를 Flask AI 서버에 전달하고, AnswerDto 로 결과 반환 */
    public AnswerDto queryAiServer(String message) {
        Map<String, String> reqBody = Map.of("message", message);
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, String>> entity = new HttpEntity<>(reqBody, headers);

        try {
            ResponseEntity<String> res = restTemplate.postForEntity(FLASK_API_URL, entity, String.class);
            String json = res.getBody();


            System.out.println("🔥 AI 원시 응답 JSON: " + json);
            System.out.println("🔻 상태코드: " + res.getStatusCode());

            ObjectMapper mapper = new ObjectMapper();
            AnswerDto dto = mapper.readValue(json, AnswerDto.class);

            System.out.println("✅ AI 응답: " + dto.getAnswer());
            System.out.println("✅ 추천 가게: " + dto.getStoreName());

            return dto;

        } catch (Exception e) {
            e.printStackTrace();
            AnswerDto fallback = new AnswerDto();
            fallback.setAnswer("AI 응답 처리 실패: " + e.getMessage());
            fallback.setStores(null);
            return fallback;
        }
    }
}