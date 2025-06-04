package com.example.fixmytown.reaction;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.report.Report;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

@Entity
@Data
public class Reaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private ReactionType type;

    @ManyToOne
    private AppUser user;

    @ManyToOne
    @JoinColumn(name = "report_id")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Report report;
}
