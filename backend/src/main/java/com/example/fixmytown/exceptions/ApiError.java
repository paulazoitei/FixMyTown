package com.example.fixmytown.exceptions;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.ZonedDateTime;

@Getter
@AllArgsConstructor
public class ApiError {
    private final String message;
    private final int status;
    private final String error;
    private final String path;
    private final ZonedDateTime timestamp;
}