package de.thws.securemessenger.features.friendshiping.adapter;

import de.thws.securemessenger.features.authorization.application.CurrentAccount;
import de.thws.securemessenger.features.friendshiping.logic.FriendshipService;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.Friendship;
import jakarta.persistence.EntityManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;


@RestController
@RequestMapping("/friendships")
public class FriendshipController {

    @Autowired
    private FriendshipService friendshipRequestService;
    private final CurrentAccount currentAccount;

    @Autowired
    EntityManager entityManager;

    public FriendshipController(FriendshipService friendshipRequestService, CurrentAccount currentAccount) {
        this.friendshipRequestService = friendshipRequestService;
        this.currentAccount = currentAccount;
    }

    @GetMapping("/")
    public ResponseEntity<List<Friendship>> getAllFriendshipRequests() {
        return ResponseEntity.ok().body(friendshipRequestService.getAllFriendshipRequestsById(currentAccount.getAccount()));
    }

    @GetMapping("/{toAccountId}")
    public ResponseEntity<Friendship> getFriendshipRequestById(@PathVariable long toAccountId) {
        Optional<Friendship> result = friendshipRequestService.getFriendshipRequestByAccount(this.currentAccount.getAccount(), entityManager.find(Account.class, toAccountId));
        return result.map(friendship -> ResponseEntity.ok().body(friendship)).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping("/{toAccountId}")
    public ResponseEntity<Long> createFriendshipRequest(@PathVariable long toAccountId) {
        return ResponseEntity.of(Optional.of(friendshipRequestService.createFriendshipRequest(this.currentAccount.getAccount(), entityManager.find(Account.class, toAccountId))));
    }

    @DeleteMapping("/{toAccountId}")
    public ResponseEntity<Void> deleteFriendshipRequest(@PathVariable long toAccountId) {
        boolean succeeded = friendshipRequestService.deleteFriendshipRequest(currentAccount.getAccount(), entityManager.find(Account.class, toAccountId));
        return succeeded ? ResponseEntity.noContent().build() : ResponseEntity.notFound().build();
    }
}

