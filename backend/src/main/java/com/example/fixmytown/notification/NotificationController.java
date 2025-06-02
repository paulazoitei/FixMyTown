package com.example.fixmytown.notification;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.appuser.AppUserRepository;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/notifications")
public class NotificationController {

    private final NotificationRepository notificationRepo;
    private final AppUserRepository userRepo;

    public NotificationController(NotificationRepository notificationRepo, AppUserRepository userRepo) {
        this.notificationRepo = notificationRepo;
        this.userRepo = userRepo;
    }

    @GetMapping
    public List<NotificationEntity> getUserNotifications() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        AppUser user = userRepo.findByEmail(email).orElseThrow();
        return notificationRepo.findByUser(user);
    }
}
