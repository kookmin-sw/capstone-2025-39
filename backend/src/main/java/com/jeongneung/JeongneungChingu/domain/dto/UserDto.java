package com.jeongneung.JeongneungChingu.domain.dto;


import lombok.*;

public class UserDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Signup {
        private String name;
        private String password;
        private String email;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Login {
        private String email;
        private String password;
    }
}