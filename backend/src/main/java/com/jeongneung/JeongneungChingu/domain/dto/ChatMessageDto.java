package com.jeongneung.JeongneungChingu.domain.dto;


import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.annotation.Nullable;
import jakarta.persistence.Column;
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


    @JsonProperty("isUser")
    private boolean isUser;

    @Column(name = "place_name")
    private String placeName;
}