package de.thws.securemessenger.model;
import jakarta.persistence.*;
import jakarta.transaction.Transactional;
import org.hibernate.annotations.GenericGenerator;

import java.time.Instant;
import java.util.LinkedList;
import java.util.List;

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

    @Column(length = 16383)
    private String value;

    @OneToMany(cascade = CascadeType.ALL)
    @JoinColumn(name = "message_id")
    private List<AttachedFile> attachedFiles = new LinkedList<>();

    private Instant timeStamp;
    private Instant lastTimeUpdated;
    private Instant selfDestructionTime;

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

    public Message(long id, Account fromUser, Chat chat, String value, List<AttachedFile> attachedFiles, Instant timeStamp) {
        this.id = id;
        this.fromUser = fromUser;
        this.chat = chat;
        this.value = value;
        this.attachedFiles = attachedFiles;
        this.timeStamp = timeStamp;
        this.lastTimeUpdated = null;
    }

    public Message(long id, Account fromUser, Chat chat, String value, List<AttachedFile> attachedFiles, Instant timeStamp, Instant selfDestructionTime) {
        this.id = id;
        this.fromUser = fromUser;
        this.chat = chat;
        this.value = value;
        this.attachedFiles = attachedFiles;
        this.timeStamp = timeStamp;
        this.selfDestructionTime = selfDestructionTime;
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

    @Transactional
    public List<AttachedFile> getAttachedFiles() {
        return attachedFiles;
    }

    public void setAttachedFiles(List<AttachedFile> attachedFiles) {
        this.attachedFiles = attachedFiles;
    }

    public Instant selfDestructionTime() {
        return selfDestructionTime;
    }

    public void setSelfDestructionTime(Instant selfDestructionTime) {
        this.selfDestructionTime = selfDestructionTime;
    }
}
