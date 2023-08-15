package de.thws.securemessenger.features.friendshiping.adapter;

import de.thws.securemessenger.features.authorization.application.CurrentAccount;
import de.thws.securemessenger.features.friendshiping.logic.FriendshipService;
import de.thws.securemessenger.features.friendshiping.model.FriendshipResponse;
import de.thws.securemessenger.features.friendshiping.model.FriendshipWithResponse;
import de.thws.securemessenger.model.Friendship;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;
import java.util.Optional;


@RestController
@RequestMapping("/friendships")
public class FriendshipController {

    private final FriendshipService friendshipRequestService;
    private final CurrentAccount currentAccount;

    @Autowired
    public FriendshipController(FriendshipService friendshipRequestService, CurrentAccount currentAccount) {
        this.friendshipRequestService = friendshipRequestService;
        this.currentAccount = currentAccount;
    }

    @PostMapping("/{toAccountId:[0-9+]}")
    public ResponseEntity<Void> createFriendship(@PathVariable long toAccountId) throws URISyntaxException {
        Optional<Long> friendshipId = friendshipRequestService.handleFriendshipRequest(currentAccount.getAccount(), toAccountId);

        if (friendshipId.isEmpty()) {
            return ResponseEntity
                    .notFound()
                    .build();
        }

        return ResponseEntity
                .created(new URI("/friendships/" + friendshipId))
                .build();
    }

    @GetMapping("/{toAccountId:[0-9+]}")
    public ResponseEntity<Friendship> getFriendship(@PathVariable long toAccountId) {
        Optional<Friendship> friendship = friendshipRequestService.getFriendshipWith(currentAccount.getAccount(), toAccountId);
        return friendship
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{toAccountId:[0-9+]}")
    public ResponseEntity<Void> deleteFriendship(@PathVariable long toAccountId) {
        if (friendshipRequestService.deleteFriendshipRequest(currentAccount.getAccount(), toAccountId)){
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping()
    public ResponseEntity<List<FriendshipResponse>> getAllFriendships() {
        return ResponseEntity.ok(friendshipRequestService.getAllAcceptedFriendships(currentAccount.getAccount()));
    }

    @GetMapping("/with")
    public ResponseEntity<List<FriendshipWithResponse>> getAllFriendshipsWithoutOwnAccountInformation() {
        var result = friendshipRequestService
                .getAllAcceptedFriendships(currentAccount.getAccount())
                .stream()
                .map(friendship -> new FriendshipWithResponse(friendship, currentAccount.getAccount().id()))
                .toList();

        return ResponseEntity.ok(result);
    }

    @GetMapping("/incoming")
    public ResponseEntity<List<Friendship>> getIncomingFriendshipRequests(@RequestParam(defaultValue = "false") boolean showOnlyPending){
        return ResponseEntity.ok(friendshipRequestService.getAllIncomingFriendshipRequests(currentAccount.getAccount(), showOnlyPending));
    }

    @GetMapping("/outgoing")
    public ResponseEntity<List<Friendship>> getOutgoingFriendshipRequests(@RequestParam(defaultValue = "false") boolean showOnlyPending){
        return ResponseEntity.ok(friendshipRequestService.getAllOutgoingFriendshipRequests(currentAccount.getAccount(), showOnlyPending));
    }
}
