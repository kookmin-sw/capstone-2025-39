package com.jeongneung.JeongneungChingu.domain.entity;

import jakarta.persistence.*;

@Entity
public class Answer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String content; 
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id") // Answer는 Question과 다대일 관계
    private Question question;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id") // Answer는 User와 다대일 관계
    private User user;

    // 기본 생성자
    public Answer() {}

    // Getter/Setter 메소드
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Question getQuestion() {
        return question;
    }

    public void setQuestion(Question question) {
        this.question = question;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
