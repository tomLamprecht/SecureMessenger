package de.thws.securemessenger.features.authorization.model;

public record AuthorizationData(String signature, String publicKey, String timestamp, String method, String path, String requestBody) {
}
