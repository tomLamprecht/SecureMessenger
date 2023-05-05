package de.thws.biedermann.messenger.demo.friendRequest.adapter;

import de.thws.biedermann.messenger.demo.chat.model.Message;
import de.thws.biedermann.messenger.demo.friendRequest.model.Friendship;
import de.thws.biedermann.messenger.demo.friendRequest.repository.FriendshipRepository;

import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.atomic.AtomicLong;

public class FriendshipRepositoryStub implements FriendshipRepository {

    private final Map<Long, Friendship> friendshipMap = new HashMap<>();
    private final AtomicLong counter = new AtomicLong(1);

    public FriendshipRepositoryStub() {
        friendshipMap.put(1L, new Friendship(1, 2, false));
        friendshipMap.put(1L, new Friendship(1, 3, false));
        friendshipMap.put(2L, new Friendship(3, 4, true));

    }

    @Override
    public CompletableFuture<List<Friendship>> getAllFriendshipsByUserId(long userId) {
        List<Friendship> friendships = friendshipMap.values().stream().filter(f -> f.fromUserId() == userId).toList();
        return CompletableFuture.completedFuture(friendships);
    }

    @Override
    public CompletableFuture<Optional<Friendship>> getFriendship(long fromUserId, long toUserId) {
        Optional<Friendship> friendship = friendshipMap.values().stream().filter(f -> f.fromUserId() == fromUserId && f.toUserId() == toUserId).findFirst();
        return CompletableFuture.completedFuture(friendship);
    }

    @Override
    public CompletableFuture<Optional<Long>> createFriendship(Friendship friendshipRequest) {
        friendshipMap.put(counter.get(), friendshipRequest);
        Optional<Friendship> friendship = Optional.of(new Friendship(friendshipRequest.fromUserId(), friendshipRequest.toUserId(), false));
        Long result = 1L;
        if (friendship.isEmpty()) {
            result = 0L;
        }
        return CompletableFuture.completedFuture(Optional.of(result));
    }

    @Override
    public CompletableFuture<Integer> deleteFriendship(long fromUserId, long toUserId) {
        List<Friendship> friendships = new ArrayList<>(friendshipMap.values());
        List<Friendship> filteredFriendships = friendships.stream()
                .filter(f -> f.fromUserId() == fromUserId && f.toUserId() == toUserId).toList();
        friendships.removeAll(filteredFriendships);
        int count = filteredFriendships.size();
        return CompletableFuture.completedFuture(Integer.valueOf(count));
    }

    public Optional<Friendship> writeFriendship(Friendship friendship) {
        friendshipMap.put(counter.get(), friendship);
        Friendship result = new Friendship(friendship.fromUserId(), friendship.toUserId(), friendship.accepted());
        return Optional.of(result);
    }
}
