package com.jeongneung.JeongneungChingu.service;

import com.jeongneung.JeongneungChingu.domain.entity.Place;
import com.jeongneung.JeongneungChingu.repository.PlaceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PlaceService {
    private final PlaceRepository placeRepository;

    public List<Place> searchPlaces(String keyword) {
        return placeRepository.findByNameContaining(keyword);
    }
}