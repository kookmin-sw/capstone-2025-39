package com.jeongneung.JeongneungChingu.exception;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public class CustomAuthException extends RuntimeException {
    private final HttpStatus status;

    public CustomAuthException(String message, HttpStatus status) {
        super(message);
        this.status = status;
    }

}