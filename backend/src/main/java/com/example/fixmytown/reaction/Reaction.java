package com.example.fixmytown.reaction;

import com.example.fixmytown.appuser.AppUser;
import com.example.fixmytown.report.Report;
import jakarta.persistence.*;
import lombok.Data;

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
    private Report report;
}
