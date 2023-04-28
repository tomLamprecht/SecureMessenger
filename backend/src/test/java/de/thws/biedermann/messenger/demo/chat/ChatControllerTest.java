package de.thws.biedermann.messenger.demo.chat;

import de.thws.biedermann.messenger.demo.authorization.adapter.rest.CurrentUser;
import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.chat.model.Message;

import de.thws.biedermann.messenger.demo.chat.repository.FriendshipRepository;
import de.thws.biedermann.messenger.demo.shared.repository.InstantNowRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.ResponseEntity;
import reactor.core.publisher.Flux;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class ChatControllerTest {

    private static final long CHAT_ID = 1;
    private static final long USER_ID = 1;
    private final Instant now = Instant.parse( "2022-10-27T10:00:00.00Z" );

    private ChatController chatController;
    private ChatToUserTestStub chatToUserTestStub;
    private MessageTestStub messageTestStub;
    private Message testMessage;
    private long testMessageId;


    @BeforeEach
    void resetDatabase() {
        chatToUserTestStub = new ChatToUserTestStub();
        messageTestStub = new MessageTestStub();
        CurrentUser currentUser = new CurrentUser();
        currentUser.setUser( new User( USER_ID, "MAX MUSTERMANN" ) );

        FriendshipRepository friendshipRepositoryMock = mock( FriendshipRepository.class );
        InstantNowRepository instantNowRepositoryMock = mock( InstantNowRepository.class );
        when( instantNowRepositoryMock.get() ).thenReturn( now );

        chatController = new ChatController( currentUser, chatToUserTestStub, messageTestStub, friendshipRepositoryMock, instantNowRepositoryMock, new ChatSubscriptionPublisher() );

        testMessage = new Message( -1, USER_ID, CHAT_ID, "THIS IS A TEST MESSAGE", now );
        testMessageId = messageTestStub.writeMessage( testMessage );
    }

    @Test
    void getMessages() {
        ResponseEntity<List<Message>> result = chatController.getMessages( CHAT_ID );

        assertEquals( List.of( testMessage ), result.getBody() );
    }

    @Test
    void deleteMessage() {
        chatController.deleteMessage( testMessageId );

        assertTrue( messageTestStub.getMessage( testMessageId ).isEmpty() );
    }

    @Test
    void postMessage() {
        String messageValue = "TEST MESSAGE FOR POST";

        chatController.postMessage( CHAT_ID, new Message( -1, USER_ID, CHAT_ID, messageValue, now ) );

        List<Message> allMessagesOfChat = messageTestStub.messagesOfChatBetween( CHAT_ID, null );

        assertTrue( allMessagesOfChat.stream().map( Message::value ).toList().contains( messageValue ) );
    }

    @Test
    void getMessageStream() {
        final int messagesSent = 10;
        List<Message> messagesToFlux = new ArrayList<>();
        Flux<Message> flux = chatController.getMessageStream( CHAT_ID );
        flux.subscribe( messagesToFlux::add );

        for ( int i = 0; i < messagesSent; i++ )
            chatController.postMessage( CHAT_ID, testMessage );

        chatController.postMessage( CHAT_ID + 1, testMessage );

        assertEquals( messagesSent, messagesToFlux.size() );
        assertTrue( messagesToFlux.stream().allMatch( m -> m.value().equals( testMessage.value() ) ) );
    }
}