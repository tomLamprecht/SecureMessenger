package de.thws.securemessenger.features.messenging.model;

import java.util.List;

public record AddAccountsToGroupRequest(List<AccountToChat> accountToChatList) {
}
