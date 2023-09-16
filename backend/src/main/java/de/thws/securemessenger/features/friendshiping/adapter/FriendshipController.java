package de.thws.securemessenger.features.friendshiping.adapter;

import de.thws.securemessenger.features.authorization.application.CurrentAccount;
import de.thws.securemessenger.features.friendshiping.logic.FriendshipService;
import de.thws.securemessenger.features.friendshiping.model.FriendshipResponse;
import de.thws.securemessenger.features.friendshiping.model.FriendshipWithResponse;
import de.thws.securemessenger.model.Friendship;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

    private static final Logger logger = LoggerFactory.getLogger( FriendshipController.class);

    private final FriendshipService friendshipRequestService;
    private final CurrentAccount currentAccount;

    @Autowired
    public FriendshipController(FriendshipService friendshipRequestService, CurrentAccount currentAccount) {
        this.friendshipRequestService = friendshipRequestService;
        this.currentAccount = currentAccount;
    }

    @PostMapping("/{toAccountId}")
    public ResponseEntity<Void> createFriendship(@PathVariable long toAccountId) throws URISyntaxException {
        if (toAccountId == currentAccount.getAccount().id()) {
            logger.debug( "User with account id  "  +  currentAccount.getAccount().id() +" tried to create a friendship with himself. Returning 400 BAD REQUEST" );
            return ResponseEntity.badRequest().build();
        }

        Optional<Long> friendshipId = friendshipRequestService.handleFriendshipRequest(currentAccount.getAccount(), toAccountId);

        if (friendshipId.isEmpty()) {
            return ResponseEntity
                    .notFound()
                    .build();
        }

        return ResponseEntity
                .created(new URI("/friendships/" + friendshipId.get()))
                .build();
    }

    @GetMapping("/{toAccountId:-?[0-9]+}")
    public ResponseEntity<Friendship> getFriendship(@PathVariable long toAccountId) {
        Optional<Friendship> friendship = friendshipRequestService.getFriendshipWith(currentAccount.getAccount(), toAccountId);
        return friendship
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping()
    public ResponseEntity<List<FriendshipResponse>> getAllFriendships() {
        return ResponseEntity.ok(friendshipRequestService.getAllAcceptedFriendships(currentAccount.getAccount()));
    }

    @DeleteMapping("/{friendAccountId:-?[0-9]+}")
    public ResponseEntity<Void> deleteFriendship(@PathVariable long friendAccountId) {
        if (friendshipRequestService.deleteFriendshipBetween(currentAccount.getAccount(), friendAccountId)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
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
    public ResponseEntity<List<FriendshipResponse>> getIncomingFriendshipRequests(@RequestParam(defaultValue = "false") boolean showOnlyPending){
        var result = friendshipRequestService.getAllIncomingFriendshipRequests(currentAccount.getAccount(), showOnlyPending).stream().toList();
        return ResponseEntity.ok(result);
    }

    @GetMapping("/outgoing")
    public ResponseEntity<List<Friendship>> getOutgoingFriendshipRequests(@RequestParam(defaultValue = "false") boolean showOnlyPending){
        return ResponseEntity.ok(friendshipRequestService.getAllOutgoingFriendshipRequests(currentAccount.getAccount(), showOnlyPending));
    }


}
