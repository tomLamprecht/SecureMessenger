package de.thws.securemessenger.features.accounts.modules;

import de.thws.securemessenger.model.Account;

public record PublicAccountInformation(long accountId, String userName, String publicKey) {

    public PublicAccountInformation(Account account) {
        this(account.id(), account.username(), account.publicKey());
    }

}
