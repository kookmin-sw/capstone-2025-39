package com.jeongneung.JeongneungChingu.domain.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import java.util.List;

@Data
public class AnswerDto {
    @JsonProperty("response")
    private String answer;

    private List<String> stores; // ← JSON 키가 그대로 'stores'일 경우 매핑됨
}