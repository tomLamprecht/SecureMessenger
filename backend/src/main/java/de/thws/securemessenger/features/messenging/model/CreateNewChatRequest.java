package de.thws.securemessenger.features.messenging.model;

import java.util.List;

public record CreateNewChatRequest(String chatName, String description, List<AccountIdToEncryptedSymKey> accountIdToEncryptedSymKeys) {
}
