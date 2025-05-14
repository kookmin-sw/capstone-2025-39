package com.jeongneung.JeongneungChingu.domain.dto;

import lombok.Data;

@Data
public class ChatSaveRequest {
    private ChatMessageDto userMessage;
    private String aiResponse;
}