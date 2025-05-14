package com.jeongneung.JeongneungChingu.api;

import com.jeongneung.JeongneungChingu.domain.dto.WeatherDto;
import com.jeongneung.JeongneungChingu.service.WeatherService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@RestController
@RequestMapping("/api/weather")
public class WeatherController {

    private final WeatherService weatherService;

    public WeatherController(WeatherService weatherService) {
        this.weatherService = weatherService;
    }

    @GetMapping
    public ResponseEntity<WeatherDto> getWeather(
            @RequestParam(value = "time", required = false) String time) {

        if (time == null) {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmm");
            time = LocalDateTime.now().format(formatter);
        }

        WeatherDto dto = weatherService.getSimpleWeather(time);
        return ResponseEntity.ok(dto);
    }
}