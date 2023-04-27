package de.thws.biedermann.messenger.demo.chat.adapter;

import de.thws.biedermann.messenger.demo.authorization.adapter.rest.CurrentUser;
import de.thws.biedermann.messenger.demo.chat.logic.ChatSubscriber;
import de.thws.biedermann.messenger.demo.chat.logic.UserChatLogic;
import de.thws.biedermann.messenger.demo.chat.model.Message;
import de.thws.biedermann.messenger.demo.chat.repository.ChatToUserRepository;
import de.thws.biedermann.messenger.demo.chat.repository.FriendshipRepository;
import de.thws.biedermann.messenger.demo.chat.repository.MessageRepository;
import de.thws.biedermann.messenger.demo.shared.repository.InstantNowRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Sinks;

import java.time.Instant;
import java.util.List;

@RestController
@RequestMapping( "/chat" )
public class ChatController {


    private final CurrentUser currentUser;
    private final ChatSubscriptionPublisher chatSubscriptionPublisher;
    private final UserChatLogic userChatLogic;

    @Autowired
    public ChatController(
            CurrentUser currentUser,
            ChatToUserRepository chatToUserRepository,
            MessageRepository messageRepository,
            FriendshipRepository friendshipRepository,
            InstantNowRepository instantNowRepository,
            ChatSubscriptionPublisher chatSubscriptionPublisher ) {
        this.currentUser = currentUser;
        this.chatSubscriptionPublisher = chatSubscriptionPublisher;
        this.userChatLogic = new UserChatLogic( chatToUserRepository, messageRepository, friendshipRepository, instantNowRepository );
    }


    @GetMapping( "/{chat_id}" )
    public ResponseEntity<List<Message>> getMessages( @PathVariable( "chat_id" ) long chatId ) {
        return ResponseEntity.of( userChatLogic.loadMessages( currentUser.getUser(), chatId ) );
    }

    @DeleteMapping( "/messages/{message_id}" )
    public ResponseEntity<Void> deleteMessage( @PathVariable( "message_id" ) long messageId ) {
        boolean succeeded = userChatLogic.deleteMessage( currentUser.getUser(), messageId );

        return succeeded ? ResponseEntity.status( HttpStatus.NO_CONTENT ).build() : ResponseEntity.status( HttpStatus.NOT_FOUND ).build();
    }

    @PostMapping( "/{chat_id}" )
    public ResponseEntity<Void> postMessage( @PathVariable( "chat_id" ) long chatId, Message message ) {
        final Message internalMessage = new Message( -1, currentUser.getUser().id(), chatId, message.value(), Instant.now() );

        boolean succeeded = userChatLogic.writeNewMessageToChat( currentUser.getUser(), chatId, message );

        if ( succeeded )
            this.chatSubscriptionPublisher.notifyChatSubscriptions( chatId, message );

        return succeeded ? ResponseEntity.status( HttpStatus.NO_CONTENT ).build() : ResponseEntity.status( HttpStatus.NOT_FOUND ).build();
    }


    @GetMapping( "/{chat_id}/sub" )
    public Flux<Message> getMessageStream( @PathVariable( "chat_id" ) long chatId ) {
        Sinks.Many<Message> sink = Sinks.many().unicast().onBackpressureBuffer();
        Flux<Message> hotFlux = sink.asFlux().publish().autoConnect();

        var chatSubscriber = ChatSubscriber.of( chatId, sink, hotFlux );

        this.chatSubscriptionPublisher.subscribe( chatSubscriber );

        hotFlux.doFinally( s -> chatSubscriptionPublisher.unsubscribe( chatSubscriber ) );

        return hotFlux;
    }


}