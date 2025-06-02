package com.example.fixmytown.notification;

import com.example.fixmytown.appuser.AppUser;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepo;

    public NotificationService(NotificationRepository notificationRepo) {
        this.notificationRepo = notificationRepo;
    }

    public void saveNotification(AppUser user, String title, String body) {
        NotificationEntity notification = new NotificationEntity();
        notification.setUser(user);
        notification.setTitle(title);
        notification.setBody(body);
        notification.setTimestamp(LocalDateTime.now());

        notificationRepo.save(notification);
    }
}
