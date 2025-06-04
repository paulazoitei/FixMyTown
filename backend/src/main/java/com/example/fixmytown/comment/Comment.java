package com.example.fixmytown.comment;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.report.Report;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDateTime;

@Entity
@Data
public class Comment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 500)
    private String content;

    private LocalDateTime createdAt;

    @ManyToOne
    private AppUser user;

    @ManyToOne
    @JoinColumn(name = "report_id")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Report report;

}
