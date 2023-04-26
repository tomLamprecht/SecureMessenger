package de.thws.biedermann.messenger.demo.friendRequest.model;

import java.io.Serializable;

public class FriendshipId implements Serializable {

    private Long fromUserId;
    private Long toUserId;

    public FriendshipId(Long fromUserId, Long toUserId) {
        this.fromUserId = fromUserId;
        this.toUserId = toUserId;
    }
}
