package com.jeongneung.JeongneungChingu.repository;

import com.jeongneung.JeongneungChingu.domain.entity.Like;
import com.jeongneung.JeongneungChingu.domain.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

public interface LikeRepository extends JpaRepository<Like, Long> {

    Optional<Like> findByUserAndPlaceName(User user, String placeName);

    long countByPlaceName(String placeName);

    @Modifying
    @Transactional
    void deleteByUserAndPlaceName(User user, String placeName);
}
