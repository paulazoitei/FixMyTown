package com.example.fixmytown.notification;

import com.example.fixmytown.appuser.AppUser;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface NotificationTokenRepository extends JpaRepository<NotificationTokenEntity, Long> {
    Optional<NotificationTokenEntity> findByUser(AppUser user);
    Optional<NotificationTokenEntity> findByToken(String token);
    void deleteByUser(AppUser user);

}
