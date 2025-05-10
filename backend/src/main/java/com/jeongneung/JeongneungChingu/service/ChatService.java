package com.jeongneung.JeongneungChingu.service;

import com.jeongneung.JeongneungChingu.domain.dto.ChatMessageDto;
import com.jeongneung.JeongneungChingu.domain.entity.ChatMessage;
import com.jeongneung.JeongneungChingu.domain.entity.User;
import com.jeongneung.JeongneungChingu.repository.ChatMessageRepository;
import com.jeongneung.JeongneungChingu.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatMessageRepository chatMessageRepository;
    private final UserRepository userRepository;

    private User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("사용자 없음"));
    }

    public void saveAllMessages(String email, List<ChatMessageDto> messages) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("사용자 없음"));

        for (ChatMessageDto dto : messages) {
            chatMessageRepository.save(ChatMessage.builder()
                    .user(user)
                    .text(dto.getText())
                    .isUser(dto.isUser())
                    .time(dto.getTime())
                    .date(dto.getDate())
                    .lat(dto.getLat())
                    .lng(dto.getLng())
                    .roomId(dto.getRoomId())
                    .build());
        }
    }

    public void deleteRoomByUserAndRoomId(String email, int roomId) {
        User user = findUserByEmail(email);
        chatMessageRepository.deleteByUserAndRoomId(user, roomId);
    }

<<<<<<< HEAD
=======

>>>>>>> master
    public List<ChatMessageDto> getAllMessagesForUser(String email) {
        User user = findUserByEmail(email);
        List<ChatMessage> allMessages = chatMessageRepository.findByUserOrderByIdAsc(user);

        return allMessages.stream()
<<<<<<< HEAD
=======
                .filter(chat -> chat.getText() != null && !chat.getText().trim().isEmpty()) // 👈 텍스트 없는 메시지 제거
>>>>>>> master
                .map(chat -> ChatMessageDto.builder()
                        .text(chat.getText())
                        .isUser(chat.isUser())
                        .time(chat.getTime())
                        .date(chat.getDate())
                        .lat(chat.getLat())
                        .lng(chat.getLng())
                        .roomId(chat.getRoomId())
                        .build())
                .toList();
    }

<<<<<<< HEAD
=======

>>>>>>> master
    public List<ChatMessageDto> getMessagesForUserByRoomId(String email, int roomId) {
        User user = findUserByEmail(email);
        List<ChatMessage> messages = chatMessageRepository.findByUserAndRoomIdOrderByIdAsc(user, roomId);

        return messages.stream()
                .map(chat -> ChatMessageDto.builder()
                        .text(chat.getText())
                        .isUser(chat.isUser())
                        .time(chat.getTime())
                        .date(chat.getDate())
                        .lat(chat.getLat())
                        .lng(chat.getLng())
                        .roomId(chat.getRoomId())
                        .build())
                .toList();
    }
}
