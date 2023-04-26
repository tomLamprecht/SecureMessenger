package de.thws.biedermann.messenger.demo.friendRequest.model;

import jakarta.persistence.*;

@Entity
@Table(name = "friendship")
public class FriendshipRequest {

    @Id
    @Column(name = "from_user_id")
    private long fromUserId;

    @Id
    @Column(name = "to_user_id")
    private long toUserId;

    @Column(name = "accepted")
    private boolean accepted;

    public FriendshipRequest() {
    }

    public FriendshipRequest(long fromUserId, long toUserId, boolean accepted) {
        this.fromUserId = fromUserId;
        this.toUserId = toUserId;
        this.accepted = accepted;
    }

    public long getFromUserId() {
        return fromUserId;
    }

    public void setFromUserId(long fromUserId) {
        this.fromUserId = fromUserId;
    }

    public long getToUserId() {
        return toUserId;
    }

    public void setToUserId(long toUserId) {
        this.toUserId = toUserId;
    }

    public boolean isAccepted() {
        return accepted;
    }

    public void setAccepted(boolean accepted) {
        this.accepted = accepted;
    }


    @Override
    public String toString() {
        return "FriendshipRequest{" +
                ", fromUserId=" + fromUserId +
                ", toUserId=" + toUserId +
                ", accepted=" + accepted +
                '}';
    }
}

