package de.thws.biedermann.messenger.demo.chat.repository;

import de.thws.biedermann.messenger.demo.chat.model.Friendship;

import java.util.Optional;

public interface FriendshipRepository {

    Optional<Friendship> readFriendship(long fromUserId, long toUserId );
}
