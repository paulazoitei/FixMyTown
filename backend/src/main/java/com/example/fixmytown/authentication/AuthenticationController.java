package com.example.fixmytown.authentication;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.appuser.AppUserService;
import com.example.fixmytown.security.jwt.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthenticationController {

    private final AuthenticationManager authenticationManager;
    private final AppUserService appUserService;
    private final JwtService jwtService;

    @PostMapping("/login")
    public AuthenticationResponse authenticate(@RequestBody AuthenticationRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        UserDetails userDetails = appUserService.loadUserByUsername(request.getEmail());
        AppUser user = (AppUser) userDetails;

        String role = user.getAuthorities().iterator().next().getAuthority();
        String jwtToken = jwtService.generateLoginToken(user.getUsername(), role);

        return new AuthenticationResponse(jwtToken, user.getId());

    }
}
