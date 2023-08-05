package de.thws.securemessenger.features.messenging.model;

import de.thws.securemessenger.model.Account;

public class AccountToFrontend {

    private long id;
    private String username;


    public AccountToFrontend( Account account ) {
        this.id = account.id();
        this.username = account.username();
    }

    public AccountToFrontend() {
    }

    public AccountToFrontend( long id, String username ) {
        this.id = id;
        this.username = username;
    }

    public long getId() {
        return id;
    }

    public void setId( long id ) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername( String username ) {
        this.username = username;
    }
}
