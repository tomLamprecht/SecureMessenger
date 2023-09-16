package de.thws.securemessenger.model;

import jakarta.persistence.*;
import org.hibernate.annotations.GenericGenerator;

import java.time.Instant;

@Entity
@Table(
        uniqueConstraints =
        @UniqueConstraint(columnNames = {"ChatId", "AccountId"})
)
public class ChatToAccount {
    @Id
    @GeneratedValue(generator = "randomLong")
    @GenericGenerator(name = "randomLong", strategy = "de.thws.securemessenger.util.RandomLongIdentifier")
    private long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "AccountId")
    private Account account;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "ChatId")
    private Chat chat;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name ="encrypted_by")
    private Account encryptedBy;

    private String key;
    private boolean isAdmin;
    private Instant joinedAt;
    private Instant leftAt;

    public ChatToAccount() {
    }

    public ChatToAccount(long id, Account account, Account encryptedBy, Chat chat, String key, boolean isAdmin, Instant joinedAt, Instant leftAt) {
        this.id = id;
        this.account = account;
        this.chat = chat;
        this.key = key;
        this.encryptedBy = encryptedBy;
        this.isAdmin = isAdmin;
        this.joinedAt = joinedAt;
        this.leftAt = leftAt;
    }

    public long id() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public Account account() {
        return account;
    }

    public Account encryptedBy(){
        return encryptedBy;
    }

    public void setAccount(Account account) {
        this.account = account;
    }

    public Chat chat() {
        return chat;
    }

    public void setChat(Chat chat) {
        this.chat = chat;
    }

    public String key() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public boolean isAdmin() {
        return isAdmin;
    }

    public void setAdmin(boolean admin) {
        isAdmin = admin;
    }

    public Instant joinedAt() {
        return joinedAt;
    }

    public void setJoinedAt(Instant joinedAt) {
        this.joinedAt = joinedAt;
    }

    public Instant leftAt() {
        return leftAt;
    }

    public void setLeftAt(Instant leftAt) {
        this.leftAt = leftAt;
    }
}
