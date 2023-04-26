package de.thws.biedermann.messenger.demo.friendRequest.repository;

import de.thws.biedermann.messenger.demo.friendRequest.model.FriendshipId;
import de.thws.biedermann.messenger.demo.friendRequest.model.FriendshipRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FriendshipRequestRepository extends JpaRepository<FriendshipRequest, FriendshipId> {

    Optional<FriendshipRequest> findByFromUserIdAndToUserId(Long fromUserId, Long toUserId);

}

