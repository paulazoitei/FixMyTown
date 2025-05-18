package com.example.fixmytown.report;

import com.example.fixmytown.appuser.AppUser;
import jakarta.persistence.*;
import lombok.Data;


@Entity
@Data
public class Report {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String description;
    private double latitude;
    private double longitude;
    private String imageUrl;
    private String zone;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private AppUser user;
}
