package de.thws.biedermann.messenger.demo.friendRequest.logic;
import de.thws.biedermann.messenger.demo.friendRequest.model.Friendship;
import de.thws.biedermann.messenger.demo.friendRequest.repository.FriendshipRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ExecutionException;


@Service
public class FriendshipService {

    @Autowired
    private final FriendshipRepository friendshipRequestRepository;
    private final Logger logger;

    public FriendshipService(FriendshipRepository friendshipRequestRepository) {
        this.friendshipRequestRepository = friendshipRequestRepository;
        this.logger = LoggerFactory.getLogger(FriendshipService.class);
    }

    public List<Friendship> getAllFriendshipRequestsById(long userId) {
        try {
            return friendshipRequestRepository.getAllFriendshipsByUserId(userId).get();
        } catch (InterruptedException | ExecutionException e) {
            logger.error(e.getMessage());
            return List.of();
        }
    }

    public Optional<Friendship> getFriendshipRequestById(long fromUserId, long toUserId) {
        try {
            return friendshipRequestRepository.getFriendship(fromUserId, toUserId).get();
        } catch (InterruptedException | ExecutionException e) {
            logger.error(e.getMessage());
            return Optional.empty();
        }
    }

    public Optional<Long> createFriendshipRequest(long fromUserId, long toUserId) {
        Friendship friendship = new Friendship(fromUserId, toUserId, false);
        try {
            return friendshipRequestRepository.createFriendship(friendship).get();
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            return Optional.empty();
        }
    }


    public int deleteFriendshipRequest(long fromUserId, long toUserId) {
        try {
            return friendshipRequestRepository.deleteFriendship(fromUserId, toUserId).get();
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            return 0;
        }
    }
}

