package com.jeongneung.JeongneungChingu.domain.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import java.util.List;

@Data
public class AnswerDto {
    @JsonProperty("response")
    private String answer;

    private List<String> stores;

    @JsonProperty("store_name")
    private String storeName;
}