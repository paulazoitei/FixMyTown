package com.example.fixmytown.notification;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.appuser.AppUserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.transaction.annotation.Transactional;


import java.util.Map;

@RestController
@RequestMapping("/api/v1/user/fcm-token")
public class NotificationTokenController {

    private final NotificationTokenRepository tokenRepo;
    private final AppUserRepository userRepo;

    public NotificationTokenController(NotificationTokenRepository tokenRepo, AppUserRepository userRepo) {
        this.tokenRepo = tokenRepo;
        this.userRepo = userRepo;
    }

    @PostMapping
    public ResponseEntity<?> saveToken(@RequestBody Map<String, String> body) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        AppUser user = userRepo.findByEmail(email).orElseThrow();

        String token = body.get("token");

        tokenRepo.findByUser(user).ifPresent(tokenRepo::delete); // sterge tokenul vechi (1 la 1)
        // elimină dacă alt user a avut același token
        tokenRepo.findByToken(token).ifPresent(tokenRepo::delete);
        NotificationTokenEntity entity = new NotificationTokenEntity();
        entity.setToken(token);
        entity.setUser(user);

        tokenRepo.save(entity);
        return ResponseEntity.ok().build();
    }
    @Transactional
    @DeleteMapping
    public ResponseEntity<?> deleteToken() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        AppUser user = userRepo.findByEmail(email).orElseThrow();

        tokenRepo.deleteByUser(user);
        return ResponseEntity.ok().build();
    }
}
