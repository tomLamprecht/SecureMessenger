package de.thws.biedermann.messenger.demo.chat.model;

import java.time.Instant;

public record Chat(long id, long ownerId, String name, String description, Instant createdAt) {
}
