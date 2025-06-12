package com.example.fixmytown.appuser;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/user")
public class AppUserController {

    private final AppUserRepository userRepository;

    @Autowired
    public AppUserController(AppUserRepository userRepository) {
        this.userRepository = userRepository;
    }


}
