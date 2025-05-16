package com.jeongneung.JeongneungChingu.service;

import com.jeongneung.JeongneungChingu.domain.entity.Like;
import com.jeongneung.JeongneungChingu.domain.entity.User;
import com.jeongneung.JeongneungChingu.repository.LikeRepository;
import com.jeongneung.JeongneungChingu.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LikeService {

    private final LikeRepository likeRepository;
    private final UserRepository userRepository;

    @Transactional
    public void like(String email, String placeName) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("유저를 찾을 수 없습니다"));

        boolean alreadyLiked = likeRepository.findByUserAndPlaceName(user, placeName).isPresent();
        if (alreadyLiked) {
            throw new RuntimeException("이미 좋아요를 누른 장소입니다.");
        }

        Like like = Like.builder()
                .user(user)
                .placeName(placeName)
                .build();

        likeRepository.save(like);
    }

    public long countLikes(String placeName) {
        return likeRepository.countByPlaceName(placeName);
    }

    @Transactional
    public void unlike(String email, String placeName) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("유저를 찾을 수 없습니다"));

        likeRepository.deleteByUserAndPlaceName(user, placeName);
    }
}
