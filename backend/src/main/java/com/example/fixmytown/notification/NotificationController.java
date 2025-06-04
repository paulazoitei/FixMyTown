package com.example.fixmytown.notification;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.appuser.AppUserRepository;
import com.example.fixmytown.appuser.AppUserRole;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

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
        return notificationRepo.findByUserOrderByTimestampDesc(user);
    }
    @GetMapping("/admin")
    public List<NotificationEntity> getAdminNotifications() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        AppUser admin = userRepo.findByEmail(email).orElseThrow();

        if (admin.getAppUserRole() != AppUserRole.ADMIN) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only admins can access this endpoint.");
        }

        return notificationRepo.findByUserOrderByTimestampDesc(admin);
    }


}
