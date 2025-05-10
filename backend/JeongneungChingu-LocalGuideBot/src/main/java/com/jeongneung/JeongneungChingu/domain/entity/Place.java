package com.jeongneung.JeongneungChingu.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Place {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String category;
    private String address;
    private String phone;

    @Column(length = 1000)
    private String description;

    private Double lat;
    private Double lng;
}
