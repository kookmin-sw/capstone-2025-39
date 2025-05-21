package com.jeongneung.JeongneungChingu.service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.*;

@Service
@RequiredArgsConstructor
public class NaverLocalSearchService {

    @Value("${naver.api.id}")
    private String clientId;

    @Value("${naver.api.secret}")
    private String clientSecret;

    private final RestTemplate restTemplate;

    public Optional<double[]> getCoordinatesFromLocalSearch(String keyword) {
        try {
            // 1. 검색어 정리
            String cleaned = keyword
                    .replaceAll("^(서울시|서울특별시|성북구|정릉동)", "")
                    .replaceAll("\\s+", " ")
                    .replaceAll("\"", "")
                    .trim();
            String finalKeyword = "정릉동 " + cleaned;

            // 2. URI 생성
            URI uri = UriComponentsBuilder
                    .fromUriString("https://openapi.naver.com")
                    .path("/v1/search/local.json")
                    .queryParam("query", finalKeyword)
                    .queryParam("display", 1)
                    .queryParam("start", 1)
                    .queryParam("sort", "random")
                    .encode(StandardCharsets.UTF_8)
                    .build()
                    .toUri();

            // 3. 헤더 설정
            HttpHeaders headers = new HttpHeaders();
            headers.set("X-Naver-Client-Id", clientId);
            headers.set("X-Naver-Client-Secret", clientSecret);
            headers.setContentType(MediaType.APPLICATION_JSON);

            // 4. 요청 수행
            HttpEntity<Void> requestEntity = new HttpEntity<>(headers);
            ResponseEntity<Map> response = restTemplate.exchange(uri, HttpMethod.GET, requestEntity, Map.class);

            // 5. 응답 디버깅
            System.out.println("📦 지역 검색 응답 바디: " + new ObjectMapper().writeValueAsString(response.getBody()));

            // 6. 응답 파싱
            List<Map<String, Object>> items = (List<Map<String, Object>>) response.getBody().get("items");

            if (items != null && !items.isEmpty()) {
                Map<String, Object> place = items.get(0);

                // TM128 좌표 → WGS84 보정
                double mapx = Double.parseDouble(place.get("mapx").toString());
                double mapy = Double.parseDouble(place.get("mapy").toString());

                double[] coords = convertTm128ToWgs84(mapx, mapy);
                return Optional.of(coords);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return Optional.empty();
    }

    // ✅ TM128 → WGS84 좌표계 변환
    private double[] convertTm128ToWgs84(double mapX, double mapY) {
        // TM128은 x=1270000000, y=375000000 기준
        double lon = mapX / 10000000.0;
        double lat = mapY / 10000000.0;
        return new double[]{lat, lon};
    }
}
