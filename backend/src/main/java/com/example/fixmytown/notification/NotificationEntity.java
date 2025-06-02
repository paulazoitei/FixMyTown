package com.example.fixmytown.notification;

import com.example.fixmytown.appuser.AppUser;
import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Data
public class NotificationEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String body;
    private LocalDateTime timestamp;

    @ManyToOne
    private AppUser user;
}
