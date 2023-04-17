package de.thws.biedermann.messenger.demo.authorization.model;

public record AuthorizationData(String timestamp, String hashedBody, String signedMsg) {
}
