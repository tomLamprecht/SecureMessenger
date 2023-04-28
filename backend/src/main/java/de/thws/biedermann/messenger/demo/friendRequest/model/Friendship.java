package de.thws.biedermann.messenger.demo.friendRequest.model;

public record Friendship(long fromUserId, long toUserId, boolean accepted) {

    public Friendship withAccepted(boolean accepted) {
        return new Friendship(this.fromUserId, this.toUserId, accepted);
    }
}


