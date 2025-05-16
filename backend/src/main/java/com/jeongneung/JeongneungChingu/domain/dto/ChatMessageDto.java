package com.jeongneung.JeongneungChingu.domain.dto;


import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.annotation.Nullable;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessageDto {

    @JsonProperty("text")
    private String text;


    private String time;


    private String date;

    @Nullable
    private Double lat;

    @Nullable
    private Double lng;

    private int roomId;

    private boolean isUser;
}