package de.thws.biedermann.messenger.demo.friendRequest.logic;

import de.thws.biedermann.messenger.demo.friendRequest.model.FriendshipRequest;
import de.thws.biedermann.messenger.demo.friendRequest.repository.FriendshipRequestRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class FriendshipRequestService {

    @Autowired
    private FriendshipRequestRepository friendshipRequestRepository;

    public List<FriendshipRequest> getAllFriendshipRequests() {
        return friendshipRequestRepository.findAll();
    }

    public Optional<FriendshipRequest> getFriendshipRequestById(Long fromUserId, Long toUserId) {
        return friendshipRequestRepository.findByFromUserIdAndToUserId(fromUserId, toUserId);
    }

    public Optional<FriendshipRequest> createFriendshipRequest(FriendshipRequest friendshipRequest) {
        return Optional.of(friendshipRequestRepository.save(friendshipRequest));
    }

    public Optional<FriendshipRequest> updateFriendshipRequest(Long fromUserId, Long toUserId, FriendshipRequest friendshipRequest) {
        Optional<FriendshipRequest> existingRequest = friendshipRequestRepository.findByFromUserIdAndToUserId(fromUserId, toUserId);
         if(existingRequest.isEmpty()){
             return Optional.empty();
         }
        FriendshipRequest friendship = new FriendshipRequest();
        friendship.setFromUserId(friendshipRequest.getFromUserId());
        friendship.setToUserId(friendshipRequest.getToUserId());
        friendship.setAccepted(friendshipRequest.isAccepted());

        return Optional.of(friendshipRequestRepository.save(friendship));
    }

    public boolean deleteFriendshipRequest(Long fromUserId, Long toUserId) {
        Optional<FriendshipRequest> existingRequest = friendshipRequestRepository.findByFromUserIdAndToUserId(fromUserId, toUserId);
        if (existingRequest.isEmpty()) {
            return false;
        }
        friendshipRequestRepository.delete(existingRequest.get());
        return true;
    }
}

