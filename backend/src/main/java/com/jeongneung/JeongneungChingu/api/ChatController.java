package com.jeongneung.JeongneungChingu.api;


import com.jeongneung.JeongneungChingu.domain.dto.ChatMessageDto;
import com.jeongneung.JeongneungChingu.jwt.JwtTokenProvider;
import com.jeongneung.JeongneungChingu.service.AiClientService;
import lombok.RequiredArgsConstructor;
import com.jeongneung.JeongneungChingu.domain.dto.AnswerDto;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import com.jeongneung.JeongneungChingu.service.ChatService;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/chat")
public class ChatController {

    private final AiClientService aiClientService;
    private final ChatService chatService;
    private final JwtTokenProvider jwtTokenProvider;


<<<<<<< HEAD
    @PostMapping("/ask") //채팅데이터 전송
    public ResponseEntity<Map<String, String>> ask(
            @RequestBody Map<String, String> requestBody
    ) {
        try {
            String message = requestBody.get("message");
=======
    @PostMapping("/ask")
    public ResponseEntity<Map<String, String>> ask(@RequestBody Map<String, String> requestBody) {
        try {
            String message = requestBody.get("text"); // ← 여기 수정됨
            System.out.println("🟢 수신한 사용자 메시지: " + message);

>>>>>>> master
            AnswerDto aiResponse = aiClientService.queryAiServer(message);
            return ResponseEntity.ok(Map.of("response", aiResponse.getAnswer()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("response", "AI 응답 실패: " + e.getMessage()));
        }
    }


    @PostMapping("/save") //전체 대화내용 저장
    public ResponseEntity<?> saveAllChats(
            @RequestHeader("Authorization") String token,
            @RequestBody List<ChatMessageDto> messages
    ) {
        String email = jwtTokenProvider.getUserIdFromToken(token.substring(7));
        chatService.saveAllMessages(email, messages);
        return ResponseEntity.ok("채팅 전체 저장 완료");
    }


    @GetMapping("/history/{roomId}") //해당 방번호 데이터 조회
    public ResponseEntity<List<ChatMessageDto>> getUserChatsByRoom(
            @RequestHeader("Authorization") String token,
            @PathVariable int roomId
    ) {
        String email = jwtTokenProvider.getUserIdFromToken(token.substring(7));
        List<ChatMessageDto> chats = chatService.getMessagesForUserByRoomId(email, roomId);
        return ResponseEntity.ok(chats);
    }


    @DeleteMapping("/delete/{roomId}") //해당 roomId의 데이터 삭제
    public ResponseEntity<?> deleteRoom(
            @RequestHeader("Authorization") String token,
            @PathVariable int roomId
    ) {
        String email = jwtTokenProvider.getUserIdFromToken(token.substring(7));
        chatService.deleteRoomByUserAndRoomId(email, roomId);
        return ResponseEntity.ok("채팅방 삭제 완료");
    }


    @GetMapping("/rooms") // 모든 채팅방의 모든 메시지 반환
    public ResponseEntity<List<ChatMessageDto>> getAllUserMessages(
            @RequestHeader("Authorization") String token
    ) {
        String email = jwtTokenProvider.getUserIdFromToken(token.substring(7));
        List<ChatMessageDto> messages = chatService.getAllMessagesForUser(email);
        return ResponseEntity.ok(messages);
    }
}
