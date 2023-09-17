package de.thws.securemessenger.features.messenging.model;

public class WebsocketSessionKey {
    private String session;

    public WebsocketSessionKey( String session ) {
        this.session = session;
    }

    public WebsocketSessionKey() {
    }

    public String getSession() {
        return session;
    }

    public void setSession( String session ) {
        this.session = session;
    }
}
