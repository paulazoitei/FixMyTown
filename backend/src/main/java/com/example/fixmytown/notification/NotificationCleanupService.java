package com.example.fixmytown.notification;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
public class NotificationCleanupService {

    private final NotificationRepository notificationRepo;

    public NotificationCleanupService(NotificationRepository notificationRepo) {
        this.notificationRepo = notificationRepo;
    }

    @Scheduled(cron = "0 0 2 * * ?")
    public void deleteOldNotifications() {
        LocalDateTime cutoff = LocalDateTime.now().minusDays(30);
        notificationRepo.deleteByTimestampBefore(cutoff);

    }
}
