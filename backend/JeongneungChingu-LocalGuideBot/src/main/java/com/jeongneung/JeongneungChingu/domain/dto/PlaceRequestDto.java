package com.jeongneung.JeongneungChingu.domain.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class PlaceRequestDto {
    private String name;
    private String address;
}