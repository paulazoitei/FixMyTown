package com.example.fixmytown.registration;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.email.EmailSender;
import com.example.fixmytown.registration.token.ConfirmationToken;
import com.example.fixmytown.registration.token.ConfirmationTokenService;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@AllArgsConstructor
public class ConfirmationEmailService {

    private final ConfirmationTokenService confirmationTokenService;
    private final EmailSender emailSender;

    public String resendConfirmationEmail(AppUser appUser) {
        String token = UUID.randomUUID().toString();
        ConfirmationToken confirmationToken = new ConfirmationToken(
                token,
                LocalDateTime.now(),
                LocalDateTime.now().plusMinutes(15),
                appUser
        );
        confirmationTokenService.saveConfirmationToken(confirmationToken);

        String link = "http://localhost:8081/api/v1/registration/confirm?token=" + token;
        String emailContent = buildEmail(appUser.getFirstName(), link);

        emailSender.send(appUser.getEmail(), emailContent);

        return token;
    }

    private String buildEmail(String name, String link) {
        return "<div style=\"font-family:Helvetica,Arial,sans-serif;font-size:16px;margin:0;color:#0b0c0c\">" +
                "<p>Hi " + name + ",</p>" +
                "<p>Thank you for registering. Please click on the link below to activate your account:</p>" +
                "<a href=\"" + link + "\">Activate Now</a>" +
                "<p>This link will expire in 15 minutes.</p>" +
                "<p>See you soon</p>" +
                "</div>";
    }
}
