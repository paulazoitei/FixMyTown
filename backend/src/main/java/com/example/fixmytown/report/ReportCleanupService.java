package com.example.fixmytown.report;

import jakarta.transaction.Transactional;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class ReportCleanupService {

    private final ReportRepository reportRepo;

    public ReportCleanupService(ReportRepository reportRepo) {
        this.reportRepo = reportRepo;
    }

    // Rulează o dată pe zi (ex: la ora 3 noaptea)
    @Scheduled(cron = "0 0 3 * * *") // ora 03:00
    @Transactional
    public void deleteExpiredReports() {
        LocalDateTime now = LocalDateTime.now();
        reportRepo.deleteByStatusAndExpiresAtBefore("FIXED", now);
    }
}
