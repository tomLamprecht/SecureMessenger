package de.thws.biedermann.messenger.demo.friendRequest.adapter;

import de.thws.biedermann.messenger.demo.friendRequest.logic.FriendshipRequestService;
import de.thws.biedermann.messenger.demo.friendRequest.model.FriendshipRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/friendship")
public class FriendshipRequestController {

    @Autowired
    private FriendshipRequestService friendshipRequestService;

    @GetMapping("/")
    public ResponseEntity<List<FriendshipRequest>> getAllFriendshipRequests() {
        return ResponseEntity.of(Optional.ofNullable(friendshipRequestService.getAllFriendshipRequests()));
    }

    @GetMapping("/{from_user_id}/{to_user_id}")
    public ResponseEntity<FriendshipRequest> getFriendshipRequestById(@PathVariable Long fromUserId, @PathVariable Long toUserId) {
        return ResponseEntity.of(friendshipRequestService.getFriendshipRequestById(fromUserId, toUserId));
    }

    @PostMapping("/")
    public ResponseEntity<FriendshipRequest> createFriendshipRequest(@RequestBody FriendshipRequest friendshipRequest) {
        return ResponseEntity.of(friendshipRequestService.createFriendshipRequest(friendshipRequest));
    }

    @PutMapping("/{from_user_id}/{to_user_id}")
    public ResponseEntity<FriendshipRequest> updateFriendshipRequest(@PathVariable Long fromUserId, @PathVariable Long toUserId, @RequestBody FriendshipRequest friendshipRequest) {
        Optional<FriendshipRequest> updatedRequest = friendshipRequestService.updateFriendshipRequest(fromUserId, toUserId, friendshipRequest);
        if (updatedRequest.isEmpty()) {
            return ResponseEntity.notFound().build();
        } else {
            return ResponseEntity.ok(updatedRequest.get());
        }
    }

    @DeleteMapping("/{from_user_id}/{to_user_id}")
    public ResponseEntity<Void> deleteFriendshipRequest(@PathVariable Long fromUserId, @PathVariable Long toUserId) {
        boolean succeeded = friendshipRequestService.deleteFriendshipRequest(fromUserId, toUserId);
        return succeeded ? ResponseEntity.noContent().build() : ResponseEntity.notFound().build();
    }
}

