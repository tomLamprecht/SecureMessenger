package de.thws.biedermann.messenger.demo.chat.repository;

import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.chat.model.Chat;

import java.util.List;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;

public interface ChatsOverviewRepository {
    CompletableFuture<Optional<List<Chat>>> getChats(User user );
}
