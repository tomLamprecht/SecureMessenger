package de.thws.securemessenger.features.messenging.application;

import de.thws.securemessenger.features.authorization.application.CurrentAccount;
import de.thws.securemessenger.features.messenging.logic.ChatMessagesLogic;
import de.thws.securemessenger.features.messenging.logic.ChatSubscriber;
import de.thws.securemessenger.features.messenging.model.AccountToFrontend;
import de.thws.securemessenger.features.messenging.model.MessageFromFrontend;
import de.thws.securemessenger.features.messenging.model.MessageToFrontend;
import de.thws.securemessenger.model.Chat;
import de.thws.securemessenger.model.Message;
import de.thws.securemessenger.repositories.ChatRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Sinks;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping( "/chats/{chatId}/messages" )
public class MessageController {

    @Autowired
    ChatRepository chatRepository;

    private final CurrentAccount currentAccount;
    private final ChatSubscriptionPublisher chatSubscriptionPublisher;
    private final ChatMessagesLogic chatMessagesLogic;

    @Autowired
    public MessageController( CurrentAccount currentAccount, ChatSubscriptionPublisher chatSubscriptionPublisher, ChatMessagesLogic chatMessagesLogic ) {
        this.currentAccount = currentAccount;
        this.chatSubscriptionPublisher = chatSubscriptionPublisher;
        this.chatMessagesLogic = chatMessagesLogic;
    }


    @GetMapping()
    public ResponseEntity<List<MessageToFrontend>> getMessages( @PathVariable() long chatId ) {
        Optional<List<Message>> getMessages = chatMessagesLogic.getAllowedMessages( currentAccount.getAccount(), chatId );
        List<MessageToFrontend> frontendMessages = getMessages
                .map( l -> l.stream().map( MessageToFrontend::new ).collect( Collectors.toList()) )
                .orElse( new ArrayList<>() );
        Collections.sort(frontendMessages);
        Collections.reverse( frontendMessages );
        return ResponseEntity.ok( frontendMessages );
    }


    @DeleteMapping( value = "/{messageId}" )
    public ResponseEntity<Void> deleteMessage( @PathVariable() long messageId ) {
        boolean succeeded = chatMessagesLogic.deleteMessageIfAllowed( currentAccount.getAccount(), messageId );

        return succeeded ? ResponseEntity.status( HttpStatus.NO_CONTENT ).build() : ResponseEntity.status( HttpStatus.NOT_FOUND ).build();
    }

    @PostMapping()
    public ResponseEntity<Void> postMessage( @PathVariable() long chatId, @RequestBody MessageFromFrontend messageFromFrontend ) {
        Optional<Chat> chat = chatRepository.findById( chatId );
        Optional<Message> message = chat.map( c -> new Message( 0, currentAccount.getAccount(), c, messageFromFrontend.getValue(), Instant.now() ) );

        boolean succeeded = message.map( m -> chatMessagesLogic.saveMessageToChatIfAllowed( currentAccount.getAccount(), chatId, m ) ).orElse( false );

        if ( succeeded )
            this.chatSubscriptionPublisher.notifyChatSubscriptions( chatId, message.get() );

        return succeeded ? ResponseEntity.status( HttpStatus.NO_CONTENT ).build() : ResponseEntity.status( HttpStatus.NOT_FOUND ).build();
    }


    @GetMapping( "/subscription" )
    public Flux<Message> getMessageStream( @PathVariable( "chatId" ) long chatId ) {
        Sinks.Many<Message> sink = Sinks.many().unicast().onBackpressureBuffer();
        Flux<Message> hotFlux = sink.asFlux().publish().autoConnect();

        var chatSubscriber = ChatSubscriber.of( chatId, sink, hotFlux );

        this.chatSubscriptionPublisher.subscribe( chatSubscriber );

        hotFlux.doFinally( s -> chatSubscriptionPublisher.unsubscribe( chatSubscriber ) );

        return hotFlux;
    }


}