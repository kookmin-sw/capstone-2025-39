package com.jeongneung.JeongneungChingu.repository;

import com.jeongneung.JeongneungChingu.domain.entity.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface QuestionRepository extends JpaRepository<Question, Long> {

    // 특정 사용자가 작성한 질문 조회
    List<Question> findByUserId(Long userId);

    // 질문의 제목으로 질문 조회
    List<Question> findByTitleContaining(String title);

    // 특정 질문에 대한 답변 목록 조회
    List<Question> findByIdAndAnswersNotNull(Long id);
}