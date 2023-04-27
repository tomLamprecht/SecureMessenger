package de.thws.biedermann.messenger.demo.chat.model;

import java.time.Instant;

public record ChatToUser(long id, long userId, long chatId, String key, boolean isAdmin, Instant joinedAt, Instant leftAt) {
    public ChatToUser {

    }
}
