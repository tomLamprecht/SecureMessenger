package de.thws.securemessenger.features.messenging.model;

import de.thws.securemessenger.model.Chat;

import java.time.Instant;

public record ChatResponse(long id, String name, String description, Instant createdAt, String encodedGroupPic) {

    public ChatResponse(Chat chat) {
        this(chat.id(), chat.name(), chat.description(), chat.createdAt(), chat.encodedGroupPic( ) );
    }

}
