package com.jeongneung.JeongneungChingu.repository;


import com.jeongneung.JeongneungChingu.domain.entity.Place;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlaceRepository extends JpaRepository<Place, Long> {
    boolean existsByNameAndAddress(String name, String address);
}
