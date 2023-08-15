package de.thws.securemessenger.features.friendshiping.model;

import de.thws.securemessenger.model.Friendship;

public record FriendshipResponse(long id, AccountResponse fromAccount, AccountResponse toAccount, boolean accepted) {

    public FriendshipResponse(Friendship friendship) {
        this(friendship.id(), new AccountResponse(friendship.fromAccount()), new AccountResponse(friendship.toAccount()), friendship.accepted());
    }

}