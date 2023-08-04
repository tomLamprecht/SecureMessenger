package de.thws.securemessenger.features.messenging.model;

public record AccountToChat(long accountId, String encryptedSymmetricKey) {

}
