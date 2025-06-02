package com.example.fixmytown.notification;

import com.example.fixmytown.appuser.AppUser;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificationRepository extends JpaRepository<NotificationEntity, Long> {
    List<NotificationEntity> findByUser(AppUser user);
}
