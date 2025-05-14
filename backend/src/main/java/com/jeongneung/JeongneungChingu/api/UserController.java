package com.jeongneung.JeongneungChingu.api;

import com.jeongneung.JeongneungChingu.domain.dto.UserDto;
import com.jeongneung.JeongneungChingu.domain.entity.User;
import com.jeongneung.JeongneungChingu.jwt.JwtTokenProvider;
import com.jeongneung.JeongneungChingu.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;
    private final JwtTokenProvider jwtTokenProvider; // 누락되어 있던 필드 주입

    @PostMapping("/signup") //회원가입 엔드포인트
    public ResponseEntity<String> signup(@RequestBody UserDto.Signup request) {
        String result = userService.signup(request); //회원가입 로직 실행
        return ResponseEntity.ok(result); //성공,실패 메시지 반환
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody UserDto.Login request) { //LoginRequest → UserDto.Login 사용
        User user = userService.validateLogin(request.getEmail(), request.getPassword());

        String token = jwtTokenProvider.generateToken(user.getEmail()); //jwt 토큰 발급

        return ResponseEntity.ok(Map.of(  //토큰 및 사용자 아이디 반환
                "accessToken", token,
                "userId", user.getEmail()
        ));
    }
}
