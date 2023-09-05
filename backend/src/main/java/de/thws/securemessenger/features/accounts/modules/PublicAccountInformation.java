package de.thws.securemessenger.features.accounts.modules;

import de.thws.securemessenger.model.Account;

public record PublicAccountInformation(long id, String userName, String publicKey, String encodedProfilePic) {

    public PublicAccountInformation(Account account) {
        this(account.id(), account.username(), account.publicKey(), account.encodedProfilePic());
    }

}
