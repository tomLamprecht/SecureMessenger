package de.thws.biedermann.messenger.demo.chat.adapter;

import de.thws.biedermann.messenger.demo.authorization.adapter.rest.CurrentUser;
import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.chat.model.Message;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.ResponseEntity;
import reactor.core.publisher.Flux;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ChatControllerTest {

    private static final long CHAT_ID = 1;
    private static final long USER_ID = 1;

    private ChatController chatController;
    private ChatToUserTestRepository chatToUserTestRepository;
    private MessageTestRepository messageTestRepository;
    private Message testMessage;
    private long testMessageId;


    @BeforeEach
    void resetDatabase() {
        chatToUserTestRepository = new ChatToUserTestRepository();
        messageTestRepository = new MessageTestRepository();
        CurrentUser currentUser = new CurrentUser();
        currentUser.setUser( new User( USER_ID, "MAX MUSTERMANN" ) );
        chatController = new ChatController( currentUser, chatToUserTestRepository, messageTestRepository, new ChatSubscriptionPublisher() );

        testMessage = new Message( -1, USER_ID, CHAT_ID, "THIS IS A TEST MESSAGE", Instant.now() );
        testMessageId = messageTestRepository.writeMessage( testMessage );
    }

    @Test
    void getMessages() {
        ResponseEntity<List<Message>> result = chatController.getMessages( CHAT_ID );

        assertEquals( List.of( testMessage ), result.getBody() );
    }

    @Test
    void deleteMessage() {
        chatController.deleteMessage( testMessageId );

        assertTrue( messageTestRepository.getMessage( testMessageId ).isEmpty() );
    }

    @Test
    void postMessage() {
        String messageValue = "TEST MESSAGE FOR POST";

        chatController.postMessage( CHAT_ID, new Message( -1, USER_ID, CHAT_ID, messageValue, Instant.now() ) );

        List<Message> allMessagesOfChat = messageTestRepository.messagesOfChatBetween( CHAT_ID, null );

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