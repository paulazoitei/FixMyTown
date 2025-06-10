

package com.example.fixmytown.report;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.appuser.AppUserRepository;
import com.example.fixmytown.appuser.AppUserRole;
import com.example.fixmytown.firebase.FCMService;
import com.example.fixmytown.notification.NotificationService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.firebase.messaging.FirebaseMessagingException;
import okhttp3.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.bind.annotation.RequestBody;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;



@RestController
@RequestMapping("/api/v1/reports")
public class ReportController {

    @Autowired private ReportRepository reportRepo;
    @Autowired private AppUserRepository userRepo;
    @Autowired private FileStorageService fileService;
    private final ZoneDetectionService zoneDetectionService;
    private final FCMService fcmService;
    private final NotificationService notificationService;

    @Autowired
    public ReportController(
            ReportRepository reportRepo,
            AppUserRepository userRepo,
            FileStorageService fileService,
            ZoneDetectionService zoneDetectionService,
            FCMService fcmService,
            NotificationService notificationService
    ) {
        this.reportRepo = reportRepo;
        this.userRepo = userRepo;
        this.fileService = fileService;
        this.zoneDetectionService = zoneDetectionService;
        this.fcmService = fcmService;
        this.notificationService = notificationService;
    }

    @PostMapping(value = "/submit", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> submitReport(
            @RequestParam String title,
            @RequestParam String description,
            @RequestParam double latitude,
            @RequestParam double longitude,
            @RequestParam Long userId,
            @RequestParam MultipartFile image
    ) throws FirebaseMessagingException {
        AppUser user = userRepo.findById(userId).orElseThrow();
        String zone = zoneDetectionService.getZoneFromCoordinates(latitude, longitude);
        String imageUrl = fileService.save(image);

        Report report = new Report();
        report.setTitle(title);
        report.setDescription(description);
        report.setLatitude(latitude);
        report.setLongitude(longitude);
        report.setUser(user);
        report.setZone(zone);
        report.setImageUrl(imageUrl);
        report.setCreatedAt(LocalDateTime.now());

        reportRepo.save(report);

        List<AppUser> admins = userRepo.findByZoneAndAppUserRole(zone, AppUserRole.ADMIN);
        for (AppUser admin : admins) {
            String notifTitle = "New Report in Your Zone";
            String notifBody = "A new report titled '" + title + "' was submitted in " + zone + ".";
            notificationService.saveNotification(admin, notifTitle, notifBody);
            try {
                fcmService.sendNotificationToUser(admin, notifTitle, notifBody);
            } catch (Exception e) {
                e.printStackTrace(); // sau log.error(...)
            }
        }

        return ResponseEntity.ok("Report saved");
    }

    @GetMapping("/user/me")
    public List<Report> getReportsForCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        AppUser user = userRepo.findByEmail(email).orElseThrow();
        return reportRepo.findByUser(user);
    }

    @GetMapping("/admin/me")
    public List<Report> getReportsForAdminZone() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        AppUser admin = userRepo.findByEmail(email).orElseThrow();

        if (admin.getAppUserRole() != AppUserRole.ADMIN) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only admins can access this endpoint.");
        }

        return reportRepo.findByZone(admin.getZone());
    }
    @GetMapping("/all")
    public List<Report> getAllReports() {
        return reportRepo.findAll();
    }


    @PutMapping("/admin/{id}/status")
    public ResponseEntity<?> updateStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> body) throws FirebaseMessagingException {

        String newStatus = body.get("status");
        Report report = reportRepo.findById(id).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.NOT_FOUND, "Report not found"));

        report.setStatus(newStatus);
        report.setExpiresAt("Fixed".equalsIgnoreCase(newStatus) ? LocalDateTime.now().plusDays(1) : null);
        reportRepo.save(report);


        String title = report.getTitle();
        String zone = report.getZone();
        String createdFormatted = report.getCreatedAt().format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm"));

        String message = "The report titled '" + title + "' from the zone '" + zone + "' created at '" + createdFormatted + "' has changed status to: " + newStatus;


        try {
            fcmService.sendNotificationToUser(report.getUser(), "Report Status Updated", message);
        } catch (Exception e) {
            e.printStackTrace(); // Poți loga mai elegant cu un logger
        }


        notificationService.saveNotification(report.getUser(), "Report Status Updated", message);

        return ResponseEntity.ok().build();
    }


    @DeleteMapping("/admin/{id}")
    public ResponseEntity<?> deleteReportByAdmin(@PathVariable Long id) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        AppUser admin = userRepo.findByEmail(email).orElseThrow();

        if (admin.getAppUserRole() != AppUserRole.ADMIN) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only admins can delete reports.");
        }

        Report report = reportRepo.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Report not found"));
        if (!report.getZone().equals(admin.getZone())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Report does not belong to your zone.");
        }

        reportRepo.delete(report);
        return ResponseEntity.ok().build();
    }
    @Value("${openai.api.key}")
    private String openaiApiKey;
    // In ReportController.java

    @PostMapping(value = "/admin/{id}/ai-check", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<String> checkIfFake(@PathVariable Long id) throws IOException {
        Report report = reportRepo.findById(id).orElseThrow();

        String imageUrl = "https://37f3-82-77-237-107.ngrok-free.app" + report.getImageUrl();
        System.out.println("Image URL: " + imageUrl);
        String prompt = "Give a very small analyze of the report below and give a very clear conclusion it's seems to be fake or real. "
                + "Title: " + report.getTitle()
                + "\nDescription: " + report.getDescription()
                + "\nLocation: lat " + report.getLatitude() + ", lng " + report.getLongitude();


        OkHttpClient client = new OkHttpClient();


        String jsonPayload = new ObjectMapper().writeValueAsString(Map.of(
                "model", "gpt-4o",
                "messages", List.of(
                        Map.of(
                                "role", "user",
                                "content", List.of(
                                        Map.of("type", "text", "text", prompt),
                                        Map.of("type", "image_url", "image_url", Map.of("url", imageUrl))
                                )
                        )
                )
        ));


        okhttp3.MediaType mediaType = okhttp3.MediaType.get("application/json");
        okhttp3.RequestBody body = okhttp3.RequestBody.create(jsonPayload, mediaType);

        Request request = new Request.Builder()
                .url("https://api.openai.com/v1/chat/completions")
                .post(body)
                .addHeader("Authorization", "Bearer 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 " )
                .addHeader("Content-Type", "application/json")
                .build();

        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                return ResponseEntity.status(HttpStatus.BAD_GATEWAY).body("OpenAI API error: " + response.body().string());
            }
            return ResponseEntity.ok(response.body().string());
        }
    }
    @GetMapping("/admin/me/profile")
    public ResponseEntity<?> getAdminProfileWithStats() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        AppUser admin = userRepo.findByEmail(email).orElseThrow();

        if (admin.getAppUserRole() != AppUserRole.ADMIN) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only admins can access this.");
        }

        String zone = admin.getZone();

        List<Report> reports = reportRepo.findByZone(zone);
        int totalReports = reports.size();

        int reportsLastMonth = (int) reports.stream()
                .filter(r -> r.getCreatedAt().isAfter(LocalDateTime.now().minusMonths(1)))
                .count();

        int fixedReports = (int) reports.stream()
                .filter(r -> "Fixed".equalsIgnoreCase(r.getStatus()))
                .count();

        Map<String, Object> response = Map.of(
                "role", admin.getAppUserRole().name(),
                "email", admin.getEmail(),
                "firstName", admin.getFirstName(),
                "lastName", admin.getLastName(),
                "zone", zone,
                "totalReports", totalReports,
                "lastMonthReports", reportsLastMonth,
                "fixedReports", fixedReports
        );

        return ResponseEntity.ok(response);
    }
    @GetMapping("/user/me/profile")
    public ResponseEntity<?> getUserProfileWithStats() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        AppUser user = userRepo.findByEmail(email).orElseThrow();

        List<Report> reports = reportRepo.findByUser(user);
        int totalReports = reports.size();

        int fixedReports = (int) reports.stream()
                .filter(r -> "Fixed".equalsIgnoreCase(r.getStatus()))
                .count();

        int reportsThisMonth = (int) reports.stream()
                .filter(r -> r.getCreatedAt().isAfter(LocalDateTime.now().minusMonths(1)))
                .count();

        List<String> distinctZones = reports.stream()
                .map(Report::getZone)
                .filter(z -> z != null && !z.isBlank())
                .distinct()
                .toList();

        Map<String, Object> response = Map.of(
                "role", user.getAppUserRole().name(),
                "email", user.getEmail(),
                "firstName", user.getFirstName(),
                "lastName", user.getLastName(),
                "totalReports", totalReports,
                "fixedReports", fixedReports,
                "reportsThisMonth", reportsThisMonth,
                "zones", distinctZones
        );

        return ResponseEntity.ok(response);
    }




}
