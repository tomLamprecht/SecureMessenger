package de.thws.securemessenger.features.messenging.model;

import de.thws.securemessenger.model.AttachedFile;
import de.thws.securemessenger.model.Message;

import java.time.Instant;
import java.util.Base64;
import java.util.LinkedList;
import java.util.List;

public class MessageToFrontend implements Comparable<MessageToFrontend> {
    private long id;
    private String value;
    private AccountToFrontend fromAccount;
    private List<FileToFrontend> attachedFiles = new LinkedList<>();
    private Instant timestamp;

    public MessageToFrontend() {
    }

    public MessageToFrontend( Message message ){
        this.id = message.id();
        this.value = message.value();
        this.fromAccount = new AccountToFrontend(message.getFromUser());
        this.attachedFiles = message.getAttachedFiles().stream().map(file -> new FileToFrontend(file.getUuid(), file.getFileName(), file.getEncodedFileContent(), file.getCreatedAt())).toList();
        this.timestamp = message.timeStamp();
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

    public List<FileToFrontend> getAttachedFiles() {
        return attachedFiles;
    }

    public void setAttachedFiles(List<FileToFrontend> attachedFiles) {
        this.attachedFiles = attachedFiles;
    }

    @Override
    public int compareTo( MessageToFrontend o ) {
        return this.timestamp.compareTo( o.timestamp );
    }
}
