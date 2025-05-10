package com.jeongneung.JeongneungChingu.api;

import com.jeongneung.JeongneungChingu.domain.dto.PlaceRequestDto;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/places")
@RequiredArgsConstructor
public class PlaceController {

    @PostMapping("/register")
    public ResponseEntity<String> registerPlace(@RequestBody PlaceRequestDto requestDto) {
        System.out.println("📥 받은 장소 이름: " + requestDto.getName());
        System.out.println("📍 받은 주소: " + requestDto.getAddress());

        return ResponseEntity.ok("Place 등록 완료!");
    }
}