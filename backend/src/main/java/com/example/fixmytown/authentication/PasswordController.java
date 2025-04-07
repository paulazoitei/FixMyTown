package com.example.fixmytown.authentication;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.appuser.AppUserRepository;
import com.example.fixmytown.appuser.AppUserService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class PasswordController {

    private final AppUserRepository appUserRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody ChangePasswordRequest request) {
        // 1. Obține userul logat din context
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        AppUser user = appUserRepository.findByEmail(email).orElseThrow();

        // 2. Verifică parola curentă
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            return ResponseEntity.badRequest().body("Parola curentă este incorectă.");
        }

        // 3. Schimbă parola
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        appUserRepository.save(user);

        return ResponseEntity.ok("Parola a fost schimbată cu succes.");
    }
}
