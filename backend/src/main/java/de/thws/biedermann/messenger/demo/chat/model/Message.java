package de.thws.biedermann.messenger.demo.chat.model;

import java.time.Instant;

public record Message(long id, long fromUser, long chatId, String value, Instant timeStamp) {

}
