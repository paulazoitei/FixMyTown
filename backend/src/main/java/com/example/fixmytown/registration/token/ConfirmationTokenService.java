package com.example.fixmytown.registration.token;


import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.appuser.AppUserRepository;
import lombok.AllArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
@AllArgsConstructor
public class ConfirmationTokenService {

    private final ConifirmationTokenRepository conifirmationTokenRepository;


    public void saveConfirmationToken(ConfirmationToken token) {
        conifirmationTokenRepository.save(token);
    }
    public Optional<ConfirmationToken> getToken(String token) {

        return  conifirmationTokenRepository.findByToken(token);
    }

    public int setConfirmedAt(String token) {
        return  conifirmationTokenRepository.updateConfirmedAt(
                token, LocalDateTime.now());
    }
    public ConfirmationToken getLatestTokenForUser(AppUser user) {
        return conifirmationTokenRepository
                .findTopByAppUserOrderByCreatedAtDesc(user)
                .orElse(null);
    }
    @Scheduled(cron = "0 */10 * * * *")  // o dată pe minut
    public void deleteExpiredTokens() {
        conifirmationTokenRepository.deleteAllByExpiresAtBeforeAndConfirmedAtIsNull(LocalDateTime.now());
    }

    private final AppUserRepository appUserRepository;

    public AppUserRepository getAppUserRepository() {
        return appUserRepository;
    }


    public void deleteToken(ConfirmationToken existingToken) {
        conifirmationTokenRepository.delete(existingToken);
    }

}
