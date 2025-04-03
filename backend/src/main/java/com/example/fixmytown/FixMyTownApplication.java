package com.example.fixmytown;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class FixMyTownApplication {

    public static void main(String[] args) {
        SpringApplication.run(FixMyTownApplication.class, args);



    }

}
