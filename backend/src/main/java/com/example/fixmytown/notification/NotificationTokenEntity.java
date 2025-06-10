package com.example.fixmytown.notification;

import com.example.fixmytown.appuser.AppUser;
import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class NotificationTokenEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String token;

    @OneToOne
    private AppUser user;
}
