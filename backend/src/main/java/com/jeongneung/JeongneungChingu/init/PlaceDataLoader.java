package com.jeongneung.JeongneungChingu.init;

import com.jeongneung.JeongneungChingu.service.PlaceService;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.stereotype.Component;

import java.io.File;
import java.io.InputStream;

@Component
@RequiredArgsConstructor
public class PlaceDataLoader implements ApplicationRunner {

    private final PlaceService placeService;

    @Override
    public void run(ApplicationArguments args) {
        try {
            Resource[] resources = new PathMatchingResourcePatternResolver()
                    .getResources("classpath:place/*.csv");

            for (Resource resource : resources) {
                String filename = resource.getFilename();

                String category = filename
                        .replace("_크롤링_최신.csv", "")
                        .replace("정릉동", "")
                        .trim();

                System.out.println("⏳ [" + category + "] CSV import 중: " + filename);

                InputStream inputStream = resource.getInputStream();
                placeService.importPlacesFromCsv(inputStream, category); // 내부에서 중복 필터
            }

            System.out.println("✅ 모든 CSV import 완료!");

        } catch (Exception e) {
            System.err.println("❌ CSV 자동 로딩 실패: " + e.getMessage());
        }
    }

}
