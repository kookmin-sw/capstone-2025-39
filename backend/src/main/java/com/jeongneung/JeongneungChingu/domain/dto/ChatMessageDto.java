package com.jeongneung.JeongneungChingu.domain.dto;

<<<<<<< HEAD
=======
import com.fasterxml.jackson.annotation.JsonProperty;
>>>>>>> master
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class ChatMessageDto {
    private String text;
    private String time;
<<<<<<< HEAD
=======

>>>>>>> master
    private boolean isUser;
    private String date;
    private Double lat;
    private Double lng;
    private int roomId;
}
