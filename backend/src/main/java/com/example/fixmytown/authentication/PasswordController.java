package com.example.fixmytown.authentication;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.appuser.AppUserRepository;
import com.example.fixmytown.appuser.AppUserService;
import com.example.fixmytown.email.EmailSender;
import com.example.fixmytown.security.jwt.JwtService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class PasswordController {

    private final AppUserRepository appUserRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final EmailSender emailSender;

    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody ChangePasswordRequest request, @RequestHeader("Authorization") String authHeader) {
        String token = authHeader.substring(7);
        String newPassword = request.getNewPassword();

        String email;
        try {
            email = jwtService.extractEmail(token);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Invalid or expired token.");
        }


        String type = jwtService.extractTokenType(token);
        if (!"LOGIN".equals(type)) {
            return ResponseEntity.badRequest().body("Invalid token type. This token is not valid for password change.");
        }


        if (!jwtService.isTokenValid(token, email)) {
            return ResponseEntity.badRequest().body("Token invalid sau expirat.");
        }

        Optional<AppUser> userOpt = appUserRepository.findByEmail(email);
        if (userOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("User not found.");
        }

        AppUser user = userOpt.get();
        user.setPassword(passwordEncoder.encode(newPassword));
        appUserRepository.save(user);

        return ResponseEntity.ok("Password changed successfully.");
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody ForgotPasswordRequest request) {
        Optional<AppUser> userOpt = appUserRepository.findByEmail(request.getEmail());

        if (userOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Nu există cont cu acest email.");
        }

        AppUser user = userOpt.get();

        if (!user.isEnabled()) {
            return ResponseEntity.badRequest().body("Contul nu este activat. Te rugăm să confirmi emailul.");
        }

        String token = jwtService.generatePasswordResetToken(user.getEmail());


        String link = "http://192.168.56.1:8081/reset-password-page.html?token=" + token;


        emailSender.send(
                user.getEmail(),
                buildResetPasswordEmail(user.getFirstName(), link),"Forgot Password"
        );



        return ResponseEntity.ok("Email de resetare parolă trimis.");
    }
    private String buildResetPasswordEmail(String name, String link) {
        return """
                <div style="font-family: Arial, sans-serif; line-height: 1.7; padding: 22px; max-width: 600px; font-size: 16px;">
                    <h2 style="color: #333; font-size: 24px;">Hi, %s!</h2>
                    <p>We received a request to reset your password for your <strong>FixMyTown</strong> account.</p>
                    <p>Click the button below to set a new password:</p>
                    <a href="%s" style="display: inline-block; padding: 14px 28px; background-color: #007bff; color: white; text-decoration: none; border-radius: 6px; margin: 20px 0; font-size: 16px;">Reset Password</a>
                    <p>If you didn't request this, you can safely ignore this email. This link will expire in 15 minutes for your security.</p>
                    <p style="margin-top: 30px;">Thank you,<br><strong>The FixMyTown Team</strong></p>
                </div>
        """.formatted(name, link);
    }
    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody ResetPasswordRequest request) {
        String token = request.getToken();
        String newPassword = request.getNewPassword();

        String email;
        try {
            email = jwtService.extractEmail(token);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Invalid or expired token.");
        }


        String type = jwtService.extractTokenType(token);
        if (!"PASSWORD_RESET".equals(type)) {
            return ResponseEntity.badRequest().body("Invalid token type.");
        }


        if (!jwtService.isTokenValid(token, email)) {
            return ResponseEntity.badRequest().body("Token invalid sau expirat.");
        }

        Optional<AppUser> userOpt = appUserRepository.findByEmail(email);
        if (userOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("User not found.");
        }

        AppUser user = userOpt.get();

        if (!user.isEnabled()) {
            return ResponseEntity.badRequest().body("Account not activated.");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        appUserRepository.save(user);

        return ResponseEntity.ok("Your password has been successfully reset.");
    }

}
