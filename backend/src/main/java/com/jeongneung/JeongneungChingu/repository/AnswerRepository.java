package com.jeongneung.JeongneungChingu.repository;

import com.jeongneung.JeongneungChingu.domain.entity.Answer;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AnswerRepository extends JpaRepository<Answer, Long> {

    // 특정 질문에 대한 모든 답변 조회
    List<Answer> findByQuestionId(Long questionId);

    // 특정 사용자가 작성한 답변 조회
    List<Answer> findByUserId(Long userId);

    // 특정 질문에 대한 답변 존재 여부 체크
    boolean existsByQuestionId(Long questionId);
}
