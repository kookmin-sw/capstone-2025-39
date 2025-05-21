package com.jeongneung.JeongneungChingu.api;

import com.jeongneung.JeongneungChingu.domain.dto.LikeRequest;
import com.jeongneung.JeongneungChingu.jwt.JwtTokenProvider;
import com.jeongneung.JeongneungChingu.service.LikeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/likes")
@RequiredArgsConstructor
public class LikeController {

    private final LikeService likeService;
    private final JwtTokenProvider jwtTokenProvider;

    @PostMapping
    public ResponseEntity<?> like(
            @RequestHeader("Authorization") String token,
            @RequestBody LikeRequest request
    ) {
        String email = jwtTokenProvider.getUserIdFromToken(token.substring(7));
        likeService.like(email, request.getPlaceName());
        System.out.println("🧩 좋아요 요청: " + request.getPlaceName());
        return ResponseEntity.ok("좋아요 등록 완료");
    }

    @DeleteMapping
    public ResponseEntity<?> unlike(
            @RequestHeader("Authorization") String token,
            @RequestParam String placeName
    ) {
        String email = jwtTokenProvider.getUserIdFromToken(token.substring(7));
        likeService.unlike(email, placeName);
        return ResponseEntity.ok("좋아요 취소 완료");
    }

    @GetMapping("/count")
    public ResponseEntity<?> count(@RequestParam String placeName) {
        long count = likeService.countLikes(placeName);
        return ResponseEntity.ok(count);
    }

    @GetMapping("/status")
    public ResponseEntity<?> getLikeStatus(
            @RequestHeader("Authorization") String token,
            @RequestParam String placeName
    ) {
        String email = jwtTokenProvider.getUserIdFromToken(token.substring(7));

        boolean likedByUser = likeService.isLikedByUser(email, placeName);
        long likeCount = likeService.countLikes(placeName);

        return ResponseEntity.ok(
                Map.of(
                        "placeName", placeName,
                        "likedByUser", likedByUser,
                        "likeCount", likeCount
                )
        );
    }

}
