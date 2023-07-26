package de.thws.securemessenger.features.registration.models;

import java.time.Instant;

public record User(Integer id, String userName, String publicKey, Instant joinedAt) {
}
