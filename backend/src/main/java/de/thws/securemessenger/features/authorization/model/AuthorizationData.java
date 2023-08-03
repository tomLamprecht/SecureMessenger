package de.thws.securemessenger.features.authorization.model;

import java.time.Instant;

public record AuthorizationData(String signature, String publicKey, Instant timestamp, String method, String path, String requestBody) {
}
