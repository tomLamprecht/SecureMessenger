package de.thws.securemessenger.features.messenging.model;

public class MessageFromFrontend {

    private String value;

    public MessageFromFrontend() {
    }

    public MessageFromFrontend( String value ) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }

    public void setValue( String value ) {
        this.value = value;
    }
}
