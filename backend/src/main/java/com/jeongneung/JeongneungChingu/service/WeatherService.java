package com.jeongneung.JeongneungChingu.service;

import com.jeongneung.JeongneungChingu.domain.dto.WeatherDto;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.Arrays;

@Service
public class WeatherService {

    private final WebClient webClient = WebClient.create("https://apihub.kma.go.kr"); //기상청 주소

    @Value("${weather.api-key}")
    private String apiKey;


    public String getWeatherInfo(String time) {
        try {
            return webClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/api/typ01/cgi-bin/url/nph-aws2_min")
                            .queryParam("tm2", time)
                            .queryParam("stn", "414")
                            .queryParam("disp", "0")
                            .queryParam("help", "0")
                            .queryParam("authKey", apiKey)
                            .build())
                    .retrieve()
                    .onStatus(
                            status -> status.is4xxClientError() || status.is5xxServerError(),
                            clientResponse -> Mono.error(new RuntimeException("기상청 API 호출 실패: " + clientResponse.statusCode()))
                    )
                    .bodyToMono(String.class)
                    .block();
        } catch (Exception e) {
            return "날씨 정보를 가져오는 중 오류 발생: " + e.getMessage();
        }
    }
    public WeatherDto getSimpleWeather(String time) {
        String rawData = getWeatherInfo(time);
        return parseSimpleWeather(rawData);
    }

    private WeatherDto parseSimpleWeather(String rawData) { //필요한 정보만 파싱하는 함수
        String[] lines = rawData.split("\\n");
        String dataLine = Arrays.stream(lines)
                .filter(line -> !line.startsWith("#") && !line.trim().isEmpty())
                .findFirst()
                .orElseThrow(() -> new RuntimeException("데이터 라인이 존재하지 않음"));

        String[] tokens = dataLine.trim().split("\\s+");

        double temperature = Double.parseDouble(tokens[8]);
        double humidity = Double.parseDouble(tokens[14]);
        double rainfall60Min = Double.parseDouble(tokens[11]);
        double rainfallDay = Double.parseDouble(tokens[13]);

        return new WeatherDto(temperature, humidity, rainfall60Min, rainfallDay); //필요한 4개 정보만 리턴
    }
}