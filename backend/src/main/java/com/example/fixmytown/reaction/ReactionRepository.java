package com.example.fixmytown.reaction;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ReactionRepository extends JpaRepository<Reaction, Long> {
    List<Reaction> findByReportId(Long reportId);
    Optional<Reaction> findByReportIdAndUserId(Long reportId, Long userId);


}