package de.thws.securemessenger.features.messenging.model;

import de.thws.securemessenger.model.Account;

import java.time.LocalDateTime;

public record AccountResponse(long id, String userName, String publicKey, LocalDateTime joinedAt) {

    public AccountResponse(Account account){
        this(account.id(), account.username(), account.publicKey(), account.joinedAT());
    }

}
