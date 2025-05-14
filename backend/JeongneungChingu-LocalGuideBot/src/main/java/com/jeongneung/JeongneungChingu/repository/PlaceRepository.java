package com.jeongneung.JeongneungChingu.repository;


import com.jeongneung.JeongneungChingu.domain.entity.Place;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PlaceRepository extends JpaRepository<Place, Long> {

    // 장소 이름에 특정 단어가 포함된 것들 조회
    List<Place> findByNameContaining(String keyword);

    // 카테고리로 장소 필터링 (예: 음식점, 카페 등)
    List<Place> findByCategory(String category);
}
