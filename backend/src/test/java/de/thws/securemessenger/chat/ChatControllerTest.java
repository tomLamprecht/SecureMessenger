package de.thws.securemessenger.chat;

import de.thws.securemessenger.features.authorization.application.CurrentAccount;
import de.thws.securemessenger.features.messenging.application.ChatController;
import de.thws.securemessenger.features.messenging.application.ChatSubscriptionPublisher;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.Message;

import de.thws.securemessenger.repositories.FriendshipRepository;
import de.thws.securemessenger.repositories.InstantNowRepository;
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
/*
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
        CurrentAccount currentAccount = new CurrentAccount();
        currentAccount.setUser( new Account( USER_ID, "MAX MUSTERMANN", "", null ) );

        FriendshipRepository friendshipRepositoryMock = mock( FriendshipRepository.class );
        InstantNowRepository instantNowRepositoryMock = mock( InstantNowRepository.class );
        when( instantNowRepositoryMock.get() ).thenReturn( now );

        chatController = new ChatController(currentAccount, chatToUserTestStub, messageTestStub, friendshipRepositoryMock, instantNowRepositoryMock, new ChatSubscriptionPublisher() );

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
    }*/
}