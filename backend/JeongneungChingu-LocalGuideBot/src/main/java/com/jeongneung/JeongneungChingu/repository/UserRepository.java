package com.jeongneung.JeongneungChingu.repository;

import com.jeongneung.JeongneungChingu.domain.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    // 로그인용: username으로 사용자 찾기
    Optional<User> findByUsername(String username);

    // 닉네임 중복 체크 등 가능
    boolean existsByNickname(String nickname);
}