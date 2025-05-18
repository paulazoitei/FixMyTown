//package com.example.fixmytown.security.jwt;
//
//import io.jsonwebtoken.*;
//import io.jsonwebtoken.security.Keys;
//import org.springframework.stereotype.Service;
//
//import javax.crypto.SecretKey;
//import java.security.Key;
//import java.time.Instant;
//import java.util.Date;
//import java.util.UUID;
//
//@Service
//public class JwtService {
//
//    private static final String SECRET_KEY = "secret-key-12345678901234567890123456789012"; // 32+ chars
//    private static final Key KEY = Keys.hmacShaKeyFor(SECRET_KEY.getBytes());
//
//    public String generateToken(String email, int expirationMinutes) {
//        Instant now = Instant.now();
//        Instant expiration = now.plusSeconds(expirationMinutes * 60L);
//
//        return Jwts.builder()
//                .subject(email)
//                .claim("jti", UUID.randomUUID().toString()) // token ID unic
//                .issuedAt(Date.from(now))
//                .expiration(Date.from(expiration))
//                .signWith(KEY)
//                .compact();
//    }
//
//    public String extractEmail(String token) {
//        return Jwts.parser()
//                .verifyWith((SecretKey) KEY)
//                .build()
//                .parseSignedClaims(token)
//                .getPayload()
//                .getSubject();
//    }
//
//    public Date extractExpiration(String token) {
//        return Jwts.parser()
//                .verifyWith((SecretKey) KEY)
//                .build()
//                .parseSignedClaims(token)
//                .getPayload()
//                .getExpiration();
//    }
//}
//package com.example.fixmytown.security.jwt;
//
//import io.jsonwebtoken.*;
//import io.jsonwebtoken.security.Keys;
//import org.springframework.stereotype.Service;
//
//import javax.crypto.SecretKey;
//import java.security.Key;
//import java.time.Instant;
//import java.util.Date;
//import java.util.UUID;
//import java.util.function.Function;
//
//@Service
//public class JwtService {
//
//    private static final String SECRET_KEY = "12345678901234567890123456789012"; // 32+ chars
//    private static final Key KEY = Keys.hmacShaKeyFor(SECRET_KEY.getBytes());
//
//    public String generateToken(String email, int expirationMinutes, String type) {
//        Instant now = Instant.now();
//        Instant expiration = now.plusSeconds(expirationMinutes * 60L);
//
//        return Jwts.builder()
//                .subject(email)
//                .claim("type", type)
//                .claim("jti", UUID.randomUUID().toString())
//                .issuedAt(Date.from(now))
//                .expiration(Date.from(expiration))
//                .signWith(KEY)
//                .compact();
//    }
//
//
//    public String generateEmailConfirmationToken(String email) {
//        return generateToken(email, 15, "EMAIL_CONFIRMATION");
//    }
//
//    public String generatePasswordResetToken(String email) {
//        return generateToken(email, 15, "PASSWORD_RESET");
//    }
//
//
//public String generateLoginToken(String email) {
//    return generateToken(email, 15, "LOGIN");
//}
//
//
//    public String extractEmail(String token) {
//        return extractClaim(token, Claims::getSubject);
//    }
//
//    public Date extractExpiration(String token) {
//        return extractClaim(token, Claims::getExpiration);
//    }
//
//    public boolean isTokenValid(String token, String userEmail) {
//        final String username = extractEmail(token);
//        return (username.equals(userEmail) && !isTokenExpired(token));
//    }
//
//    public boolean isTokenExpired(String token) {
//        return extractExpiration(token).before(new Date());
//    }
//
//    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
//        final Claims claims = extractAllClaims(token);
//        return claimsResolver.apply(claims);
//    }
//
//    private Claims extractAllClaims(String token) {
//        return Jwts
//                .parser()
//                .verifyWith((SecretKey) KEY)
//                .build()
//                .parseSignedClaims(token)
//                .getPayload();
//    }
//    public String extractTokenType(String token) {
//        return extractClaim(token, claims -> claims.get("type", String.class));
//    }
//
//}
package com.example.fixmytown.security.jwt;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.security.Key;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;
import java.util.function.Function;

@Service
public class JwtService {

    private static final String SECRET_KEY = "12345678901234567890123456789012"; // Min. 32 chars
    private static final Key KEY = Keys.hmacShaKeyFor(SECRET_KEY.getBytes());

    // General token generation method with type and role
    public String generateTokenWithRole(String email, int expirationMinutes, String type, String role) {
        Instant now = Instant.now();
        Instant expiration = now.plusSeconds(expirationMinutes * 60L);

        return Jwts.builder()
                .subject(email)
                .claim("type", type)
                .claim("role", role)
                .claim("jti", UUID.randomUUID().toString())
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiration))
                .signWith(KEY)
                .compact();
    }

    public String generateEmailConfirmationToken(String email) {
        return generateTokenWithRole(email, 15, "EMAIL_CONFIRMATION", "NONE");
    }

    public String generatePasswordResetToken(String email) {
        return generateTokenWithRole(email, 15, "PASSWORD_RESET", "NONE");
    }

    public String generateLoginToken(String email, String role) {
        return generateTokenWithRole(email, 30240, "LOGIN", role);
    }

    public String extractEmail(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public String extractRole(String token) {
        return extractClaim(token, claims -> claims.get("role", String.class));
    }

    public String extractTokenType(String token) {
        return extractClaim(token, claims -> claims.get("type", String.class));
    }

    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    public boolean isTokenValid(String token, String userEmail) {
        final String username = extractEmail(token);
        return (username.equals(userEmail) && !isTokenExpired(token));
    }

    public boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    private Claims extractAllClaims(String token) {
        return Jwts
                .parser()
                .verifyWith((SecretKey) KEY)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
}
