package com.example.fixmytown.registration;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.appuser.AppUserRepository;
import com.example.fixmytown.email.EmailSender;
import com.example.fixmytown.registration.token.ConfirmationToken;
import com.example.fixmytown.registration.token.ConfirmationTokenService;
import com.example.fixmytown.security.jwt.JwtService;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.ZoneId;

@Service
@AllArgsConstructor
public class ConfirmationEmailService {

    private final ConfirmationTokenService confirmationTokenService;
    private final EmailSender emailSender;
    private final JwtService jwtService;
    private final AppUserRepository appUserRepository;

//    public String resendConfirmationEmail(AppUser appUser) {
//        AppUser userFromDb = appUserRepository.findByEmail(appUser.getEmail())
//                .orElseThrow(() -> new IllegalStateException("User not found"));
//
//        String token = jwtService.generateToken(userFromDb.getEmail(), 1);
//        LocalDateTime expiration = jwtService.extractExpiration(token)
//                .toInstant()
//                .atZone(ZoneId.systemDefault())
//                .toLocalDateTime();
//
//        ConfirmationToken confirmationToken = new ConfirmationToken(
//                token,
//                LocalDateTime.now(),
//                expiration,
//                userFromDb
//        );
//        confirmationTokenService.saveConfirmationToken(confirmationToken);
//
//        String link = "http://localhost:8081/api/v1/registration/confirm?token=" + token;
//        emailSender.send(userFromDb.getEmail(), buildEmail(userFromDb.getFirstName(), link));
//
//        return token;
//    }
public String resendConfirmationEmail(AppUser appUser) {
    AppUser userFromDb = appUserRepository.findByEmail(appUser.getEmail())
            .orElseThrow(() -> new IllegalStateException("User not found"));

    if (userFromDb.isEnabled()) {
        throw new IllegalStateException("User already confirmed");
    }

    ConfirmationToken existingToken = confirmationTokenService.getLatestTokenForUser(userFromDb);

    if (existingToken != null) {
        boolean isExpired = existingToken.getExpiresAt().isBefore(LocalDateTime.now());
        boolean isConfirmed = existingToken.getConfirmedAt() != null;

        if (!isExpired && !isConfirmed) {
            throw new IllegalStateException("A confirmation email was already sent. Please check your inbox.");
        }


        confirmationTokenService.deleteToken(existingToken);
    }


    String token = jwtService.generateToken(userFromDb.getEmail(), 15); // 15 minute

    LocalDateTime expiration = jwtService.extractExpiration(token)
            .toInstant()
            .atZone(ZoneId.systemDefault())
            .toLocalDateTime();

    ConfirmationToken confirmationToken = new ConfirmationToken(
            token,
            LocalDateTime.now(),
            expiration,
            userFromDb
    );
    confirmationTokenService.saveConfirmationToken(confirmationToken);

    String link = "http://localhost:8081/api/v1/registration/confirm?token=" + token;
    emailSender.send(userFromDb.getEmail(), buildEmail(userFromDb.getFirstName(), link));

    return token;
}



private String buildEmail(String name, String link) {
        return "<!DOCTYPE html>" +
                "<html lang=\"en\">" +
                "<head>" +
                "    <meta charset=\"UTF-8\">" +
                "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" +
                "    <title>Confirm your email</title>" +
                "</head>" +
                "<body style=\"font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8f9fa; padding: 20px;\">" +
                "    <table style=\"width: 100%; max-width: 600px; margin: auto; background-color: #ffffff; padding: 30px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);\">" +
                "        <tr>" +
                "            <td style=\"text-align: center; padding-bottom: 20px;\">" +
                "                <h2 style=\"color: #333333;\">Welcome to FixMyTown, " + name + "!</h2>" +
                "            </td>" +
                "        </tr>" +
                "        <tr>" +
                "            <td style=\"text-align: center; font-size: 16px; color: #555555; padding-bottom: 20px;\">" +
                "                Thank you for registering. Please click the button below to activate your account:" +
                "            </td>" +
                "        </tr>" +
                "        <tr>" +
                "            <td style=\"text-align: center;\">" +
                "                <a href=\"" + link + "\" style=\"display: inline-block; padding: 12px 24px; background-color: #007bff; color: #ffffff; text-decoration: none; border-radius: 5px; font-weight: bold;\">Activate Account</a>" +
                "            </td>" +
                "        </tr>" +
                "        <tr>" +
                "            <td style=\"padding-top: 20px; font-size: 14px; color: #888888; text-align: center;\">" +
                "                The link expires in 15 minutes." +
                "            </td>" +
                "        </tr>" +
                "        <tr>" +
                "            <td style=\"padding-top: 20px; font-size: 14px; color: #888888; text-align: center;\">" +
                "                If you didn't request this email, please ignore it." +
                "            </td>" +
                "        </tr>" +
                "        <tr>" +
                "            <td style=\"padding-top: 30px; font-size: 16px; color: #555555; text-align: center;\">" +
                "                See you soon,<br><strong>The FixMyTown Team</strong>" +
                "            </td>" +
                "        </tr>" +
                "    </table>" +
                "</body>" +
                "</html>";
    }
}