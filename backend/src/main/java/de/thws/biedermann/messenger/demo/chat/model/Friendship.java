package de.thws.biedermann.messenger.demo.chat.model;

public record Friendship(long fromUserId, long toUserId, boolean accepted) {
}
