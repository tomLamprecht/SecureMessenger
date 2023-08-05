package de.thws.securemessenger.features.messenging.model;

import de.thws.securemessenger.model.Message;

import java.time.Instant;

public class MessageToFrontend implements Comparable<MessageToFrontend> {
    private long id;
    private String value;
    private AccountToFrontend fromAccount;
    private Instant timestamp;

    public MessageToFrontend() {
    }

    public MessageToFrontend( Message message ){
        this.id = message.id();
        this.value = message.value();
        this.fromAccount = new AccountToFrontend(message.getFromUser());
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

    @Override
    public int compareTo( MessageToFrontend o ) {
        return this.timestamp.compareTo( o.timestamp );
    }
}
