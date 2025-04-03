package com.example.fixmytown.security.jwt;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.security.Key;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;

@Service
public class JwtService {

    private static final String SECRET_KEY = "secret-key-12345678901234567890123456789012"; // 32+ chars
    private static final Key KEY = Keys.hmacShaKeyFor(SECRET_KEY.getBytes());

    public String generateToken(String email, int expirationMinutes) {
        Instant now = Instant.now();
        Instant expiration = now.plusSeconds(expirationMinutes * 60L);

        return Jwts.builder()
                .subject(email)
                .claim("jti", UUID.randomUUID().toString()) // token ID unic
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiration))
                .signWith(KEY)
                .compact();
    }

    public String extractEmail(String token) {
        return Jwts.parser()
                .verifyWith((SecretKey) KEY)
                .build()
                .parseSignedClaims(token)
                .getPayload()
                .getSubject();
    }

    public Date extractExpiration(String token) {
        return Jwts.parser()
                .verifyWith((SecretKey) KEY)
                .build()
                .parseSignedClaims(token)
                .getPayload()
                .getExpiration();
    }
}
