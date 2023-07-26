package de.thws.securemessenger.features.authorization.model;

public record AuthorizationData(String timestamp, String hashedBody, String signedMsg) {
}
