package com.jeongneung.JeongneungChingu.service;

import com.jeongneung.JeongneungChingu.domain.entity.Place;
import com.jeongneung.JeongneungChingu.repository.PlaceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.io.*;

@Service
@RequiredArgsConstructor
public class PlaceService {

    private final PlaceRepository placeRepository;

    public void importPlacesFromCsv(InputStream inputStream, String category) {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream))) {
            String line;
            boolean firstLine = true;

            while ((line = br.readLine()) != null) {
                if (firstLine) {
                    firstLine = false;
                    continue;
                }

                String[] tokens = line.split(",");

                String name = tokens[0].trim();
                String phone = tokens[3].trim();
                String address = tokens[4].trim();

                if (!placeRepository.existsByNameAndAddress(name, address)) {
                    Place place = new Place();
                    place.setName(name);
                    place.setPhone(phone);
                    place.setAddress(address);
                    place.setCategory(category);
                    placeRepository.save(place);
                }
            }

        } catch (IOException e) {
            throw new RuntimeException("CSV 읽기 실패: " + e.getMessage());
        }
    }

}