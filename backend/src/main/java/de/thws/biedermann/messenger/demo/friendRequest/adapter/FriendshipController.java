package de.thws.biedermann.messenger.demo.friendRequest.adapter;

import ch.qos.logback.core.net.SyslogOutputStream;
import de.thws.biedermann.messenger.demo.authorization.adapter.rest.CurrentUser;
import de.thws.biedermann.messenger.demo.friendRequest.logic.FriendshipService;
import de.thws.biedermann.messenger.demo.friendRequest.model.Friendship;
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
    private final CurrentUser currentUser;

    public FriendshipController(FriendshipService friendshipRequestService, CurrentUser currentUser) {
        this.friendshipRequestService = friendshipRequestService;
        this.currentUser = currentUser;
    }

    @GetMapping("/")
    public ResponseEntity<List<Friendship>> getAllFriendshipRequests() {
        return ResponseEntity.ok().body(friendshipRequestService.getAllFriendshipRequestsById(currentUser.getUser().id()));
    }

    @GetMapping("/{to_user_id}")
    public ResponseEntity<Friendship> getFriendshipRequestById(@PathVariable long toUserId) {
        Optional<Friendship> result = friendshipRequestService.getFriendshipRequestById(this.currentUser.getUser().id(), toUserId);
        if (result.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok().body(result.get());
    }

    @PostMapping("/{to_user_id}")
    public ResponseEntity<Long> createFriendshipRequest(@PathVariable long toUserId) {
        return ResponseEntity.of(friendshipRequestService.createFriendshipRequest(this.currentUser.getUser().id(), toUserId));
    }

    @DeleteMapping("/{to_user_id}")
    public ResponseEntity<Integer> deleteFriendshipRequest(@PathVariable Long toUserId) {
        int succeeded = friendshipRequestService.deleteFriendshipRequest(currentUser.getUser().id(), toUserId);
        if (succeeded == 1) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}

