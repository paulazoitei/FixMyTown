package com.example.fixmytown.registration.token;


import lombok.AllArgsConstructor;
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
}
