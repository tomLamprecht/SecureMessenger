package de.thws.biedermann.messenger.demo.users.model;

import java.time.Instant;

public record User(Integer id, String userName, String publicKey, Instant joinedAt) {
}
