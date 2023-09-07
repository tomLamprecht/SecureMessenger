package de.thws.securemessenger.model;

import jakarta.persistence.*;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Entity
public class AttachedFile {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID uuid;

    private String fileName;

    @Column(columnDefinition = "TEXT")
    private String encodedFileContent;

    private Instant createdAt;

    @ManyToOne
    @JoinColumn(name = "message_id", insertable = false, updatable = false)
    private Message message;

    public AttachedFile() {
    }

    public AttachedFile(String fileName, String encodedFileContent) {
        this.fileName = fileName;
        this.encodedFileContent = encodedFileContent;
        this.createdAt = Instant.now();
    }

    public UUID getUuid() {
        return uuid;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getEncodedFileContent() {
        return encodedFileContent;
    }

    public void setEncodedFileContent(String encodedFileContent) {
        this.encodedFileContent = encodedFileContent;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    @Transactional
    public Message getMessage() {
        return message;
    }

    public void setMessage(Message message) {
        this.message = message;
    }
}
