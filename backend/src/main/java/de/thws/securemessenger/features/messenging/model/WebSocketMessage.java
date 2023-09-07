package de.thws.securemessenger.features.messenging.model;

import de.thws.securemessenger.model.Message;

import java.time.Instant;
import java.util.Base64;
import java.util.LinkedList;
import java.util.List;

public class WebSocketMessage {
    WebsocketMessageType messageType;
    private long id;
    private String value;
    private AccountToFrontend fromAccount;
    private List<FileToFrontend> attachedFiles = new LinkedList<>();
    private Instant timestamp;
    private Instant lastTimeUpdated;

    public WebSocketMessage() {
    }

    public static WebSocketMessage createDeleteMessage(long id){
        var temp = new WebSocketMessage();
        temp.setId( id );
        temp.messageType = WebsocketMessageType.DELETE;
        return temp;
    }

    public WebSocketMessage( Message message ){
        this.id = message.id();
        this.value = message.value();
        this.fromAccount = new AccountToFrontend(message.getFromUser());
        this.timestamp = message.timeStamp();
        this.attachedFiles = message.getAttachedFiles().stream().map(file -> new FileToFrontend(file.getUuid(), file.getFileName(), file.getEncodedFileContent(), file.getCreatedAt())).toList();
        this.messageType = WebsocketMessageType.CREATE;
        this.lastTimeUpdated = message.getLastTimeUpdated();
    }

    public WebSocketMessage( Message message, WebsocketMessageType messageType ) {
        this(message);
        this.messageType = messageType;
    }

    public long getId() {
        return id;
    }

    public void setId( long id ) {
        this.id = id;
    }

    public String getValue() {
        return value;
    }

    public void setValue( String value ) {
        this.value = value;
    }

    public AccountToFrontend getFromAccount() {
        return fromAccount;
    }

    public void setFromAccount( AccountToFrontend fromAccount ) {
        this.fromAccount = fromAccount;
    }

    public Instant getTimestamp() {
        return timestamp;
    }

    public void setTimestamp( Instant timestamp ) {
        this.timestamp = timestamp;
    }

    public WebsocketMessageType getMessageType() {
        return messageType;
    }

    public void setDeleteMessage( WebsocketMessageType messageType ) {
        this.messageType = messageType;
    }

    public Instant getLastTimeUpdated() {
        return lastTimeUpdated;
    }

    public void setLastTimeUpdated(Instant lastTimeUpdated) {
        this.lastTimeUpdated = lastTimeUpdated;
    }

    public void setMessageType(WebsocketMessageType messageType) {
        this.messageType = messageType;
    }

    public List<FileToFrontend> getAttachedFiles() {
        return attachedFiles;
    }

    public void setAttachedFiles(List<FileToFrontend> attachedFiles) {
        this.attachedFiles = attachedFiles;
    }
}
