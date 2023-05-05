package de.thws.biedermann.messenger.demo.friendRequest.adapter;

import de.thws.biedermann.messenger.demo.authorization.adapter.rest.CurrentUser;
import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.chat.adapter.ChatController;
import de.thws.biedermann.messenger.demo.chat.adapter.ChatSubscriptionPublisher;
import de.thws.biedermann.messenger.demo.chat.adapter.ChatToUserTestStub;
import de.thws.biedermann.messenger.demo.chat.adapter.MessageTestStub;
import de.thws.biedermann.messenger.demo.chat.model.Message;
import de.thws.biedermann.messenger.demo.chat.repository.ChatToUserRepository;
import de.thws.biedermann.messenger.demo.friendRequest.logic.FriendshipService;
import de.thws.biedermann.messenger.demo.friendRequest.model.Friendship;
import de.thws.biedermann.messenger.demo.friendRequest.repository.FriendshipRepository;
import de.thws.biedermann.messenger.demo.shared.repository.InstantNowRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

public class FriendshipControllerTest {
    private FriendshipController friendshipController;

    private static final long USER_ID = 1;
    private static final long TO_USER_ID = 2;
    private FriendshipRepositoryStub friendshipRepositoryStub;
    private Friendship testFriendship;
    private long testFriendshipId;

    @BeforeEach
    void setUp() {
        friendshipRepositoryStub = new FriendshipRepositoryStub();
        CurrentUser currentUser = new CurrentUser();
        currentUser.setUser(new User(USER_ID, "test"));

        friendshipController = new FriendshipController(new FriendshipService(friendshipRepositoryStub), currentUser);

        testFriendship = new Friendship(USER_ID, TO_USER_ID, false);
        testFriendshipId = friendshipRepositoryStub.writeFriendship(testFriendship).orElseThrow().fromUserId();

    }


    @Test
    void test_getAllFriendshipRequests() {
        ResponseEntity<List<Friendship>> result = friendshipController.getAllFriendshipRequests();
        assertEquals(List.of(testFriendship), result.getBody());
    }

    @Test
    void test_getFriendshipRequestById() {
        ResponseEntity<Friendship> result = friendshipController.getFriendshipRequestById(2L);
        assertEquals(testFriendship, result.getBody());
    }

    @Test
    void test_createFriendshipRequest() {
        ResponseEntity<Long> result = friendshipController.createFriendshipRequest(5L);
        Long expected = 1L;
        assertEquals(expected, result.getBody());
    }

    @Test
    void test_deleteFriendshipRequest() {
        ResponseEntity<Integer> result = friendshipController.deleteFriendshipRequest(2L);
        assertEquals(HttpStatus.NO_CONTENT, result.getStatusCode());
    }


}
