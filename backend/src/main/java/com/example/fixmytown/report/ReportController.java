package com.example.fixmytown.report;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.appuser.AppUserRepository;
import com.example.fixmytown.appuser.AppUserRole;
import com.example.fixmytown.firebase.FCMService;
import com.example.fixmytown.notification.NotificationService;
import com.google.firebase.messaging.FirebaseMessagingException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import java.time.format.DateTimeFormatter;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/reports")
public class ReportController {

    @Autowired
    private ReportRepository reportRepo;
    @Autowired private AppUserRepository userRepo;
    @Autowired private FileStorageService fileService;
    private  ZoneDetectionService zoneDetectionService;

    private  FCMService fcmService;
    private  NotificationService notificationService;

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
        List<AppUser> admins = userRepo.findByZoneAndAppUserRole(report.getZone(), AppUserRole.ADMIN);
        for (AppUser admin : admins) {
            String notifTitle = "New Report in Your Zone";
            String notifBody = "A new report titled '" + report.getTitle() + "' was submitted in " + report.getZone() + ".";


            notificationService.saveNotification(admin, notifTitle, notifBody);


            if (admin.getFcmToken() != null && !admin.getFcmToken().isEmpty()) {
                fcmService.sendNotification(admin.getFcmToken(), notifTitle, notifBody);
            }
        }
            return ResponseEntity.ok("Report saved");
        }


        @GetMapping("/user/me")
        public List<Report> getReportsForCurrentUser () {
            String email = SecurityContextHolder.getContext().getAuthentication().getName();
            AppUser user = userRepo.findByEmail(email).orElseThrow();
            return reportRepo.findByUser(user);
        }

        @GetMapping("/admin/me")
        public List<Report> getReportsForAdminZone () {
            String email = SecurityContextHolder.getContext().getAuthentication().getName();
            AppUser admin = userRepo.findByEmail(email).orElseThrow();

            if (admin.getAppUserRole() != AppUserRole.ADMIN) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only admins can access this endpoint.");
            }

            return reportRepo.findByZone(admin.getZone());
        }
        @PutMapping("/admin/{id}/status")
        public ResponseEntity<?> updateStatus (
                @PathVariable Long id,
                @RequestBody Map < String, String > body) throws FirebaseMessagingException {

            String newStatus = body.get("status");
            Report report = reportRepo.findById(id)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Report not found"));

            report.setStatus(newStatus);
            if ("Fixed".equalsIgnoreCase(newStatus)) {
                report.setExpiresAt(LocalDateTime.now().plusDays(1));
            } else {
                report.setExpiresAt(null);
            }

            reportRepo.save(report);


            String userToken = report.getUser().getFcmToken();


            String title = report.getTitle();
            String zone = report.getZone();
            LocalDateTime created = report.getCreatedAt();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm");
            String createdFormatted = created.format(formatter);

            String message = "The report titled '" + title + "' from the zone '" + zone +
                    "' created at '" + createdFormatted +
                    "' has changed status to: " + newStatus;

            if (userToken != null && !userToken.isBlank()) {
                fcmService.sendNotification(userToken, "Report Status Updated", message);
                notificationService.saveNotification(report.getUser(), "Report Status Updated", message);
            } else {
                System.out.println("❌ No FCM token available for user " + report.getUser().getEmail());
            }
            return ResponseEntity.ok().build();
        }

        @GetMapping("/all")
        public List<Report> getAllReports () {
            return reportRepo.findAll();
        }



}

