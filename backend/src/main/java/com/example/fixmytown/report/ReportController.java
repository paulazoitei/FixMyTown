package com.example.fixmytown.report;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.appuser.AppUserRepository;
import com.example.fixmytown.appuser.AppUserRole;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/reports")
public class ReportController {

    @Autowired
    private ReportRepository reportRepo;
    @Autowired private AppUserRepository userRepo;
    @Autowired private FileStorageService fileService;

    @PostMapping(value = "/submit", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> submitReport(
            @RequestParam String title,
            @RequestParam String description,
            @RequestParam double latitude,
            @RequestParam double longitude,
            @RequestParam Long userId,
            @RequestParam MultipartFile image
    ) {
        AppUser user = userRepo.findById(userId).orElseThrow();
        String zone = "Iași"; // sau getZoneFromCoordinates(latitude, longitude)

        String imageUrl = fileService.save(image);

        Report report = new Report();
        report.setTitle(title);
        report.setDescription(description);
        report.setLatitude(latitude);
        report.setLongitude(longitude);
        report.setUser(user);
        report.setZone(zone);
        report.setImageUrl(imageUrl);

        reportRepo.save(report);
        return ResponseEntity.ok("Report saved");
    }

    @GetMapping("/user/{userId}")
    public List<Report> getUserReports(@PathVariable Long userId) {
        AppUser user = userRepo.findById(userId).orElseThrow();
        return reportRepo.findByUser(user);
    }

    @GetMapping("/admin/{adminId}")
    public List<Report> getAdminReports(@PathVariable Long adminId) {
        AppUser admin = userRepo.findById(adminId).orElseThrow();
        if (admin.getAppUserRole() != AppUserRole.ADMIN)
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not an admin");
        return reportRepo.findByZone(admin.getZone());
    }

}

