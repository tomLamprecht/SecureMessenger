package de.thws.securemessenger.features.messenging.model;

import de.thws.securemessenger.model.ChatToAccount;

import java.time.Instant;

public record ChatToAccountResponse(long id, AccountResponse account, ChatResponse chat, String key, boolean isAdmin, Instant joinedAt, Instant leftAt, AccountResponse encryptedBy) {

    public ChatToAccountResponse(ChatToAccount chatToAccount) {
        this(chatToAccount.id(), new AccountResponse(chatToAccount.account()), new ChatResponse(chatToAccount.chat()), chatToAccount.key(), chatToAccount.isAdmin(), chatToAccount.joinedAt(), chatToAccount.leftAt(), new AccountResponse(chatToAccount.encryptedBy()));
    }

}
