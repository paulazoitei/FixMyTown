package com.example.fixmytown.exceptions;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.DisabledException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.annotation.*;

import java.time.ZonedDateTime;

@RestControllerAdvice
public class GlobalExceptionHandler {

    // 1. Email duplicat, user invalid, etc.
    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<ApiError> handleIllegalState(IllegalStateException ex, HttpServletRequest request) {
        return buildResponse(ex.getMessage(), HttpStatus.BAD_REQUEST, request);
    }

    // 2. Când metoda HTTP e greșită (ex: faci GET pe un POST)
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ApiError> handleMethodNotSupported(HttpRequestMethodNotSupportedException ex, HttpServletRequest request) {
        return buildResponse("Method not supported", HttpStatus.METHOD_NOT_ALLOWED, request);
    }

    // 3. User is disabled
    @ExceptionHandler(DisabledException.class)
    public ResponseEntity<ApiError> handleUserDisabled(DisabledException ex, HttpServletRequest request) {
        return buildResponse("User is disabled", HttpStatus.FORBIDDEN, request);
    }

    // 4. Alte excepții (fallback general)
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiError> handleAll(Exception ex, HttpServletRequest request) {
        return buildResponse("Unexpected error: " + ex.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR, request);
    }

    // Utilitar pentru a construi un răspuns standardizat
    private ResponseEntity<ApiError> buildResponse(String message, HttpStatus status, HttpServletRequest request) {
        ApiError error = new ApiError(
                message,
                status.value(),
                status.getReasonPhrase(),
                request.getRequestURI(),
                ZonedDateTime.now()
        );
        return ResponseEntity.status(status).body(error);
    }
    @ExceptionHandler(Throwable.class)
    public ResponseEntity<ApiError> handleAny(Throwable ex, HttpServletRequest request) {
        ex.printStackTrace(); // vezi exact în consolă ce s-a aruncat
        return buildResponse("Something went wrong: " + ex.getClass().getSimpleName(), HttpStatus.INTERNAL_SERVER_ERROR, request);
    }


}