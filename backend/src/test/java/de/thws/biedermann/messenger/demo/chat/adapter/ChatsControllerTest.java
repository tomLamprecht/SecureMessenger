package de.thws.biedermann.messenger.demo.chat.adapter;

import de.thws.biedermann.messenger.demo.authorization.adapter.rest.CurrentUser;
import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.chat.model.ChatToUser;
import de.thws.biedermann.messenger.demo.chat.model.Friendship;
import de.thws.biedermann.messenger.demo.chat.repository.ChatToUserRepository;
import de.thws.biedermann.messenger.demo.chat.repository.FriendshipRepository;
import de.thws.biedermann.messenger.demo.shared.repository.InstantNowRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class ChatsControllerTest {

    private ChatsController chatsController;

    private final User user = new User( 1, "test" );
    private final Instant now = Instant.parse( "2022-10-27T10:00:00.00Z" );
    private final ChatToUserRepository chatToUserRepositoryStub = new ChatToUserTestStub();

    @BeforeEach
    void setUp() {
        CurrentUser currentUser = new CurrentUser();
        currentUser.setUser( user );
        FriendshipRepository friendshipRepositoryMock = mock( FriendshipRepository.class );
        InstantNowRepository instantNowRepositoryMock = mock( InstantNowRepository.class );

        when( friendshipRepositoryMock.readFriendship( 1, 2 ) ).thenReturn( Optional.of( new Friendship( 1, 2, true ) ) );
        when( instantNowRepositoryMock.get() ).thenReturn( now );

        chatsController = new ChatsController( currentUser, chatToUserRepositoryStub , new MessageTestStub(), friendshipRepositoryMock, instantNowRepositoryMock );
    }

    @Test
    void test_chats_post() {
        ChatToUser chatToUser = new ChatToUser( -1, 2, 1, "key", false, null, null );
        ChatToUser expected = new ChatToUser( 1, 2, 1, "key", false, now, null );
        chatsController.postChatToUser( chatToUser );

        Optional<ChatToUser> result = chatToUserRepositoryStub.readChatToUser( 1 );
        assertTrue(result.isPresent());

        assertEquals( expected, result.get() );
    }

}