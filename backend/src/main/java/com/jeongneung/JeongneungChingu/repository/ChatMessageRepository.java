package com.jeongneung.JeongneungChingu.repository;

import com.jeongneung.JeongneungChingu.domain.entity.ChatMessage;
import com.jeongneung.JeongneungChingu.domain.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    // 유저별 채팅 목록 (옵션)
    List<ChatMessage> findByUser(User user);
    List<ChatMessage> findByUserOrderByIdAsc(User user);
    // 방별 채팅 목록 (옵션)
    List<ChatMessage> findByRoomId(int roomId);
    void deleteByUserAndRoomId(User user, int roomId);


    List<ChatMessage> findByUserAndRoomIdOrderByIdAsc(User user, int roomId);
}
