package de.thws.securemessenger.features.friendshiping.model;

import de.thws.securemessenger.model.Friendship;

public record FriendshipWithResponse(long id, AccountResponse withResponse, boolean accepted) {

    public FriendshipWithResponse(Friendship friendship, long currentAccountId) {
        this(
                friendship.id(),
                new AccountResponse(friendship.fromAccount().id() == currentAccountId ? friendship.fromAccount() : friendship.toAccount()),
                friendship.accepted()
        );
    }

    public FriendshipWithResponse(FriendshipResponse friendship, long currentAccountId) {
        this(
                friendship.id(),
                friendship.fromAccount().id() == currentAccountId ? friendship.fromAccount() : friendship.toAccount(),
                friendship.accepted()
        );
    }
}
