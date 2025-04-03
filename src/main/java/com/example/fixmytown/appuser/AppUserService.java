package com.example.fixmytown.appuser;

import com.example.fixmytown.registration.ConfirmationEmailService;
import com.example.fixmytown.registration.RegistrationService;
import com.example.fixmytown.registration.token.ConfirmationToken;
import com.example.fixmytown.registration.token.ConfirmationTokenService;
import lombok.AllArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
@AllArgsConstructor
public class AppUserService implements UserDetailsService {

    private final static String USER_NOT_FOUND_MSG = "user with email %s not found";
    private final AppUserRepository appUserRepository;
    private final BCryptPasswordEncoder bCryptPasswordEncoder;
    private final ConfirmationTokenService confirmationTokenService;
    private final ConfirmationEmailService confirmationEmailService;


    @Override
public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
    System.out.println("Trying to load user: " + email);
    return appUserRepository.findByEmail(email)
            .orElseThrow(() -> new UsernameNotFoundException(String.format(USER_NOT_FOUND_MSG, email)));
}

    public String signUpUser(AppUser appUser){
        Optional<AppUser> userOptional = appUserRepository.findByEmail(appUser.getEmail());

        if (userOptional.isPresent()) {
            AppUser existingUser = userOptional.get();

            boolean sameAttributes = existingUser.getFirstName().equals(appUser.getFirstName()) &&
                    existingUser.getLastName().equals(appUser.getLastName());

            if (!existingUser.isEnabled()) {
                if (sameAttributes) {

                    return confirmationEmailService.resendConfirmationEmail(existingUser);
                } else {
                    throw new IllegalStateException("Email already taken, but attributes are different");
                }
            }

            throw new IllegalStateException("email already taken");
        }
        String encodedPassword = bCryptPasswordEncoder.encode(appUser.getPassword());
        appUser.setPassword(encodedPassword);

        appUserRepository.save(appUser);
        String token = UUID.randomUUID().toString();
        ConfirmationToken confirmationToken = new ConfirmationToken(
                token,
                LocalDateTime.now(),
                LocalDateTime.now().plusMinutes(15),
                appUser
        );
        confirmationTokenService.saveConfirmationToken(confirmationToken);

        return token;
    }


    public int enableAppUser(String email) {
        return appUserRepository.enableAppUser(email);
    }
}
