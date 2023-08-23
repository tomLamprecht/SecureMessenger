package de.thws.securemessenger.model;
import jakarta.persistence.*;
import org.hibernate.annotations.GenericGenerator;

import java.time.Instant;

@Entity
public class Message {
    @Id
    @GeneratedValue(generator = "randomLong")
    @GenericGenerator(name = "randomLong", strategy = "de.thws.securemessenger.util.RandomLongIdentifier")
    private long id;

    @ManyToOne
    @JoinColumn(name = "AccountId")
    private Account fromUser;

    @ManyToOne
    @JoinColumn(name = "ChatId")
    private Chat chat;

    private String value;
    private Instant timeStamp;
    private Instant lastTimeUpdated;

    public Instant getLastTimeUpdated() {
        return lastTimeUpdated;
    }

    public Instant getTimeStamp() {
        return timeStamp;
    }

    public void setLastTimeUpdated(Instant lastTimeEdited) {
        this.lastTimeUpdated = lastTimeEdited;
    }

    public Message(){

    }

    public Message(long id, Account fromUser, Chat chat, String value, Instant timeStamp) {
        this.id = id;
        this.fromUser = fromUser;
        this.chat = chat;
        this.value = value;
        this.timeStamp = timeStamp;
        this.lastTimeUpdated = null;
    }

    public Message(long id, Account fromUser, Chat chat, String value, Instant timeStamp, Instant lastTimeUpdated) {
        this.id = id;
        this.fromUser = fromUser;
        this.chat = chat;
        this.value = value;
        this.timeStamp = timeStamp;
        this.lastTimeUpdated = lastTimeUpdated;
    }

    public long id() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public Account fromUser() {
        return fromUser;
    }

    public void setFromUser(Account fromUser) {
        this.fromUser = fromUser;
    }

    public Chat chat() {
        return chat;
    }

    public void setChat(Chat chat) {
        this.chat = chat;
    }

    public String value() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public Instant timeStamp() {
        return timeStamp;
    }

    public void setTimeStamp(Instant timeStamp) {
        this.timeStamp = timeStamp;
    }

    public String getValue() {
        return value;
    }

    public Account getFromUser() {
        return fromUser;
    }

    public Chat getChat() {
        return chat;
    }
}
