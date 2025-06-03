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


    @Scheduled(cron = "0 9 22 * * *")

    @Transactional
    public void deleteExpiredReports() {
        LocalDateTime now = LocalDateTime.now();
        reportRepo.deleteByStatusAndExpiresAtBefore("Fixed", now);
    }
}
