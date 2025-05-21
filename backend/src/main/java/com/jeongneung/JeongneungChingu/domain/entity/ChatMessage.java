package com.jeongneung.JeongneungChingu.domain.entity;



import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    private User user;

    private String text;

    private boolean isUser;

    private String placeName;

    public boolean isUser() {      // ChatService가 호출할 메서드
        return isUser;
    }
    private String time;
    private String date;
    private Double lat;
    private Double lng;
    private int roomId;
}