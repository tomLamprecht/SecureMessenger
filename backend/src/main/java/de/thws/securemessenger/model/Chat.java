package de.thws.securemessenger.model;

import jakarta.persistence.*;

import java.time.Instant;
import java.util.List;

@Entity
public class Chat {
    @Id
    @GeneratedValue
    private long id;

    private String name;
    private String description;
    private Instant createdAt;

    @OneToMany(mappedBy = "chat", fetch = FetchType.EAGER)
    private List<Message> messages;

    @OneToMany(mappedBy = "chat", fetch = FetchType.EAGER)
    private List<ChatToAccount> chatToAccounts;

    public Chat() {
    }

    public Chat(long id, String name, String description, Instant createdAt) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.createdAt = createdAt;
    }

    public List<Account> members() {
        return chatToAccounts.stream().map(ChatToAccount::account).toList();
    }

    public long id() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String name() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String description() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Instant createdAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public List<Message> messages() {
        return messages;
    }

    public void setMessages(List<Message> messages) {
        this.messages = messages;
    }

    public List<ChatToAccount> chatToAccounts() {
        return chatToAccounts;
    }

    public void setChatToAccounts(List<ChatToAccount> chatToAccounts) {
        this.chatToAccounts = chatToAccounts;
    }
}