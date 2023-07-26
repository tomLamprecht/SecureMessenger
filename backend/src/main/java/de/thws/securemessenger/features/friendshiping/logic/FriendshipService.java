package de.thws.securemessenger.features.friendshiping.logic;

import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.Friendship;
import jakarta.persistence.EntityManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;


@Service
public class FriendshipService {
    private final Logger logger;

    @Autowired
    EntityManager entityManager;

    public FriendshipService() {
        this.logger = LoggerFactory.getLogger(FriendshipService.class);
    }

    public List<Friendship> getAllFriendshipRequestsById(Account account) {
        return account.friendships();
    }

    public Optional<Friendship> getFriendshipRequestByAccount(Account fromAccount, Account toAccount) {
        return fromAccount.friendshipWith(toAccount);
    }

    public long createFriendshipRequest(Account fromAccount, Account toAccount) {
        Friendship friendship = new Friendship(0, fromAccount, toAccount, false);
        entityManager.persist(friendship);
        return friendship.id();
    }

    public boolean deleteFriendshipRequest(Account fromAccount, Account toAccount) {
        Optional<Friendship> friendship = fromAccount.friendshipWith(toAccount);
        if (friendship.isEmpty()) {
            return false;
        }
        entityManager.remove(friendship.get());
        return true;
    }
}

