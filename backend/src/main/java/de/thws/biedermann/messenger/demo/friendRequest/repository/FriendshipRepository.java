package de.thws.biedermann.messenger.demo.friendRequest.repository;

import de.thws.biedermann.messenger.demo.friendRequest.model.Friendship;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;

@Repository
public interface FriendshipRepository {

    CompletableFuture<List<Friendship>> getAllFriendshipsByUserId(long userId);

    CompletableFuture<Optional<Friendship>> getFriendship(long fromUserId, long toUserId);

    CompletableFuture<Optional<Long>> createFriendship(Friendship friendshipRequest);

    CompletableFuture<Integer> deleteFriendship(long fromUserId, long toUserId);

}

