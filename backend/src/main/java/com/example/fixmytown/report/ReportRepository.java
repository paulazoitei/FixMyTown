package com.example.fixmytown.report;

import com.example.fixmytown.appuser.AppUser;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReportRepository extends JpaRepository<Report, Long> {
    List<Report> findByUser(AppUser user);
    List<Report> findByZone(String zone);
}
