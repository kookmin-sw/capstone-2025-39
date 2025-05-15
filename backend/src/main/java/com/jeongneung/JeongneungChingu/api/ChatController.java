package com.jeongneung.JeongneungChingu.api;

import com.jeongneung.JeongneungChingu.domain.dto.AnswerDto;
import com.jeongneung.JeongneungChingu.domain.dto.ChatMessageDto;
import com.jeongneung.JeongneungChingu.jwt.JwtTokenProvider;
import com.jeongneung.JeongneungChingu.service.AiClientService;
import com.jeongneung.JeongneungChingu.service.ChatService;
import com.jeongneung.JeongneungChingu.service.NaverLocalSearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/chat")
public class ChatController {

    private final AiClientService aiClientService;
    private final ChatService chatService;
    private final JwtTokenProvider jwtTokenProvider;
    private final NaverLocalSearchService naverLocalSearchService;

    @PostMapping("/ask")
    public ResponseEntity<ChatMessageDto> ask(
            @RequestBody Map<String, String> requestBody,
            @RequestHeader("Authorization") String token
    ) {
        try {
            String message = requestBody.get("text");
            int roomId = Integer.parseInt(requestBody.getOrDefault("roomId", "0"));

            System.out.println("🟢 사용자 질문 수신: " + message);

            // AI 응답 받기
            AnswerDto aiResponse = aiClientService.queryAiServer(message);

            // 가게명 정제
            String rawStoreName = aiResponse.getStoreName();
            String cleanedStoreName = rawStoreName.replaceFirst("^정릉동\\s*", "").trim();
            String query = "정릉동 " + cleanedStoreName;

            System.out.println("📌 원본 가게명: " + rawStoreName);
            System.out.println("📌 정제된 가게명: " + cleanedStoreName);
            System.out.println("🔎 최종 검색 키워드: " + query);

            // 🔁 지역 검색 API로 좌표 가져오기
            Optional<double[]> coords = naverLocalSearchService.getCoordinatesFromLocalSearch(query);
            coords.ifPresent(c -> System.out.println("📍 네이버 좌표: " + Arrays.toString(c)));

            // 현재 날짜/시간
            String currentDate = LocalDate.now().toString();
            String currentTime = LocalTime.now().withNano(0).toString();

            ChatMessageDto responseDto = ChatMessageDto.builder()
                    .text(aiResponse.getAnswer())
                    .isUser(false)
                    .date(currentDate)
                    .time(currentTime)
                    .roomId(roomId)
                    .lat(coords.map(c -> c[0]).orElse(null))
                    .lng(coords.map(c -> c[1]).orElse(null))
                    .build();

            System.out.println("✅ 최종 응답 DTO: " + new com.fasterxml.jackson.databind.ObjectMapper().writeValueAsString(responseDto));
            return ResponseEntity.ok(responseDto);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ChatMessageDto.builder()
                            .text("AI 응답 처리 중 오류가 발생했습니다: " + e.getMessage())
                            .isUser(false)
                            .roomId(0)
                            .build());
        }
    }


    @PostMapping("/save")
    public ResponseEntity<?> saveAllChats(
            @RequestHeader("Authorization") String token,
            @RequestBody List<ChatMessageDto> messages
    ) {
        String email = jwtTokenProvider.getUserIdFromToken(token.substring(7));
        chatService.saveAllMessages(email, messages);
        return ResponseEntity.ok("채팅 전체 저장 완료");
    }

    @GetMapping("/history/{roomId}")
    public ResponseEntity<List<ChatMessageDto>> getUserChatsByRoom(
            @RequestHeader("Authorization") String token,
            @PathVariable int roomId
    ) {
        String email = jwtTokenProvider.getUserIdFromToken(token.substring(7));
        List<ChatMessageDto> chats = chatService.getMessagesForUserByRoomId(email, roomId);
        return ResponseEntity.ok(chats);
    }

    @DeleteMapping("/delete/{roomId}")
    public ResponseEntity<?> deleteRoom(
            @RequestHeader("Authorization") String token,
            @PathVariable int roomId
    ) {
        String email = jwtTokenProvider.getUserIdFromToken(token.substring(7));
        chatService.deleteRoomByUserAndRoomId(email, roomId);
        return ResponseEntity.ok("채팅방 삭제 완료");
    }

    @GetMapping("/rooms")
    public ResponseEntity<List<ChatMessageDto>> getAllUserMessages(
            @RequestHeader("Authorization") String token
    ) {
        String email = jwtTokenProvider.getUserIdFromToken(token.substring(7));
        List<ChatMessageDto> messages = chatService.getAllMessagesForUser(email);
        return ResponseEntity.ok(messages);
    }
}
