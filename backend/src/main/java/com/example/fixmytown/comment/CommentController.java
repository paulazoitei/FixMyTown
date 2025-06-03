package com.example.fixmytown.comment;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.appuser.AppUserRepository;
import com.example.fixmytown.report.Report;
import com.example.fixmytown.report.ReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/comments")
@RequiredArgsConstructor
public class CommentController {

    private final CommentRepository commentRepo;
    private final AppUserRepository userRepo;
    private final ReportRepository reportRepo;

    @PostMapping("/{reportId}")
    public ResponseEntity<?> addComment(@PathVariable Long reportId, @RequestBody Map<String, String> body) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        AppUser user = userRepo.findByEmail(email).orElseThrow();
        Report report = reportRepo.findById(reportId).orElseThrow();

        Comment comment = new Comment();
        comment.setContent(body.get("content"));
        comment.setCreatedAt(LocalDateTime.now());
        comment.setUser(user);
        comment.setReport(report);

        commentRepo.save(comment);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{reportId}")
    public List<Comment> getComments(@PathVariable Long reportId) {
        return commentRepo.findByReportId(reportId);
    }
    @DeleteMapping("/{commentId}")
    public ResponseEntity<?> deleteComment(@PathVariable Long commentId) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        AppUser currentUser = userRepo.findByEmail(email).orElseThrow();

        Comment comment = commentRepo.findById(commentId).orElseThrow();
        Report report = comment.getReport();

        boolean isCommentOwner = comment.getUser().getId().equals(currentUser.getId());
        boolean isReportOwner = report.getUser().getId().equals(currentUser.getId());

        if (isCommentOwner || isReportOwner) {
            commentRepo.delete(comment);
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Not allowed to delete this comment.");
        }
    }

}
