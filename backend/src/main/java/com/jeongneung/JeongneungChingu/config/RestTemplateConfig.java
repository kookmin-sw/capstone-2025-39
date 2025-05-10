package com.jeongneung.JeongneungChingu.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.web.client.RestTemplate;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

@Configuration
public class RestTemplateConfig {

    @Bean
    public RestTemplate restTemplate() {
        RestTemplate restTemplate = new RestTemplate();

        // ✅ UTF-8 문자열 + JSON 둘 다 지원하는 컨버터 등록
        List<HttpMessageConverter<?>> converters = new ArrayList<>();
        converters.add(new StringHttpMessageConverter(StandardCharsets.UTF_8)); // 텍스트 응답용
        converters.add(new MappingJackson2HttpMessageConverter());              // JSON 응답용

        restTemplate.setMessageConverters(converters);
        return restTemplate;
    }
}
