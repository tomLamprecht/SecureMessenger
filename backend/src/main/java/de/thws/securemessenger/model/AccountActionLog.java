package de.thws.securemessenger.model;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
public class AccountActionLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;

    @Column(nullable = false)
    public String accountPublicKey;

    @Column(nullable = false)
    public String uri;

    @CreationTimestamp
    public LocalDateTime timestamp;

    public AccountActionLog() {

    }

    public AccountActionLog(String accountPublicKey, String uri) {
        this.accountPublicKey = accountPublicKey;
        this.uri = uri;
    }

    public AccountActionLog(Long id, String accountPublicKey, String uri, LocalDateTime timestamp) {
        this.id = id;
        this.accountPublicKey = accountPublicKey;
        this.uri = uri;
        this.timestamp = timestamp;
    }
}
