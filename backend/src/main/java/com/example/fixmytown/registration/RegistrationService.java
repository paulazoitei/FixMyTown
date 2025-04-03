

package com.example.fixmytown.registration;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.appuser.AppUserRepository;
import com.example.fixmytown.appuser.AppUserRole;
import com.example.fixmytown.appuser.AppUserService;
import com.example.fixmytown.email.EmailSender;
import com.example.fixmytown.registration.token.ConfirmationToken;
import com.example.fixmytown.registration.token.ConfirmationTokenService;
import com.example.fixmytown.security.jwt.JwtService;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.ZoneId;

@Service
@AllArgsConstructor
public class RegistrationService {
    private final AppUserService appUserService;
    private final EmailValidator emailValidator;
    private final ConfirmationTokenService confirmationTokenService;
    private final EmailSender emailSender;
    private final JwtService jwtService;
    private final AppUserRepository appUserRepository;
    private final AppUserRepository userRepository;
    private final ConfirmationEmailService confirmationEmailService;

    public String register(RegistrationRequest request) {
        boolean isValidEmail = emailValidator.test(request.getEmail());
        if (!isValidEmail) {
            throw new IllegalStateException("email not valid");
        }

        AppUser user = new AppUser(
                request.getFirstName(),
                request.getLastName(),
                request.getEmail(),
                request.getPassword(),
                AppUserRole.USER
        );

        String token = appUserService.signUpUser(user);

        // Fetch user from DB to avoid transient error
        AppUser savedUser = appUserRepository.findByEmail(user.getEmail())
                .orElseThrow(() -> new IllegalStateException("User not found after registration"));

        LocalDateTime expiration = jwtService.extractExpiration(token)
                .toInstant()
                .atZone(ZoneId.systemDefault())
                .toLocalDateTime();

        boolean tokenExists = confirmationTokenService.getToken(token).isPresent();
        if (!tokenExists) {
            ConfirmationToken confirmationToken = new ConfirmationToken(
                    token,
                    LocalDateTime.now(),
                    expiration,
                    savedUser
            );
            confirmationTokenService.saveConfirmationToken(confirmationToken);
        }

        String link = "http://localhost:8081/api/v1/registration/confirm?token=" + token;
        emailSender.send(request.getEmail(), buildEmail(savedUser.getFirstName(), link));

        return token;
    }

    @Transactional
    public String confirmToken(String token) {
        ConfirmationToken confirmationToken = confirmationTokenService.getToken(token)
                .orElseThrow(() -> new IllegalStateException("token not found"));

        if (confirmationToken.getConfirmedAt() != null) {
            throw new IllegalStateException("email already confirmed");
        }

        if (confirmationToken.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new IllegalStateException("token expired");
        }

        confirmationTokenService.setConfirmedAt(token);
        appUserService.enableAppUser(confirmationToken.getAppUser().getEmail());
        return "confirmed";
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


