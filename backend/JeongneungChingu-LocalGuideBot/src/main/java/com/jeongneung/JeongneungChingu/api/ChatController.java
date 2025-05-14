package com.jeongneung.JeongneungChingu.api;


import com.jeongneung.JeongneungChingu.service.AiClientService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/chat")
public class ChatController {

    private final AiClientService aiClientService;

    public ChatController(AiClientService aiClientService) {
        this.aiClientService = aiClientService;
    }

    @PostMapping
    public ResponseEntity<String> chat(@RequestBody Map<String, String> req) {
        String message = req.get("message");
        System.out.println("🗨️ 사용자 질문: " + message);

        String aiResponse = aiClientService.queryAiServer(message);

        return ResponseEntity.ok(aiResponse);
    }
}
