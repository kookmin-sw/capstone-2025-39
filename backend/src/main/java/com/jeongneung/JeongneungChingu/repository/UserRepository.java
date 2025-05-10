package com.jeongneung.JeongneungChingu.repository;

import com.jeongneung.JeongneungChingu.domain.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.List;

public interface UserRepository extends JpaRepository<User, Long> {

    // 이메일로 사용자 조회 (중복된 이메일이 없다고 가정)
    Optional<User> findByEmail(String email);

    // 사용자 이름으로 검색
    List<User> findByNameContaining(String name);

    // 이메일로 사용자 존재 여부 확인
    boolean existsByEmail(String email);

    // 특정 사용자 삭제
    void deleteByEmail(String email);

}
