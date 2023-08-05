package de.thws.securemessenger.features.messenging.model;

public class MessageFrontend {

    private String value;

    public MessageFrontend() {
    }

    public MessageFrontend( String value ) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }

    public void setValue( String value ) {
        this.value = value;
    }
}
