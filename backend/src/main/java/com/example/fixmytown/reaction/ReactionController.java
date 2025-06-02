package com.example.fixmytown.reaction;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.appuser.AppUserRepository;
import com.example.fixmytown.report.Report;
import com.example.fixmytown.report.ReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/reactions")
@RequiredArgsConstructor
public class ReactionController {

    private final ReactionRepository reactionRepo;
    private final AppUserRepository userRepo;
    private final ReportRepository reportRepo;

    @PostMapping("/{reportId}")
    public ResponseEntity<?> react(@PathVariable Long reportId, @RequestBody Map<String, String> body) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        AppUser user = userRepo.findByEmail(email).orElseThrow();
        Report report = reportRepo.findById(reportId).orElseThrow();

        ReactionType type = ReactionType.valueOf(body.get("type"));

        // Suprascrie reacția anterioară dacă există
        Reaction reaction = reactionRepo.findByReportIdAndUserId(reportId, user.getId())
                .orElse(new Reaction());

        reaction.setUser(user);
        reaction.setReport(report);
        reaction.setType(type);

        reactionRepo.save(reaction);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{reportId}")
    public List<Reaction> getReactions(@PathVariable Long reportId) {
        return reactionRepo.findByReportId(reportId);
    }
}
