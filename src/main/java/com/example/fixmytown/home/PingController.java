package com.example.fixmytown.home;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class PingController {
    @GetMapping("/")
    public String index() {
        return "Logged in!";
    }
}