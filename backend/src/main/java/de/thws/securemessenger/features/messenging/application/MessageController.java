package de.thws.securemessenger.features.messenging.application;

import de.thws.securemessenger.features.authorization.application.CurrentAccount;
import de.thws.securemessenger.features.messenging.logic.ChatMessagesLogic;
import de.thws.securemessenger.features.messenging.logic.WebSocketSessionLogic;
import de.thws.securemessenger.features.messenging.model.MessageFromFrontend;
import de.thws.securemessenger.features.messenging.model.MessageToFrontend;
import de.thws.securemessenger.features.messenging.model.UpdateMessageRequest;
import de.thws.securemessenger.features.messenging.model.WebsocketSessionKey;
import de.thws.securemessenger.model.ApiExceptions.UnauthorizedException;
import de.thws.securemessenger.model.Chat;
import de.thws.securemessenger.model.AttachedFile;
import de.thws.securemessenger.model.Message;
import de.thws.securemessenger.repositories.ChatRepository;
import de.thws.securemessenger.util.FileResourceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.FileNotFoundException;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping( "/chats/{chatId}/messages" )
public class MessageController {

    private static final String DEFAULT_MAX_MESSAGES_SIZE = "100";

    @Autowired
    ChatRepository chatRepository;

    @Autowired
    WebSocketSessionLogic webSocketSessionLogic;

    private final CurrentAccount currentAccount;
    private final SubscriptionWebSocket chatSubscriptionWebsocket;
    private final ChatMessagesLogic chatMessagesLogic;


    @Autowired
    public MessageController( CurrentAccount currentAccount, SubscriptionWebSocket chatSubscriptionWebsocket, ChatMessagesLogic chatMessagesLogic, FileResourceService fileResourceService ) throws FileNotFoundException {
        this.currentAccount = currentAccount;
        this.chatSubscriptionWebsocket = chatSubscriptionWebsocket;
        this.chatMessagesLogic = chatMessagesLogic;

    }


    @GetMapping()
    public ResponseEntity<List<MessageToFrontend>> getMessages( @PathVariable() long chatId, @RequestParam(defaultValue = "-1") long latestMessageId, @RequestParam(defaultValue = DEFAULT_MAX_MESSAGES_SIZE) int maxSize ) {
        if(maxSize <= 0)
            return ResponseEntity.ok().build();
       Optional<List<Message>> getMessages = chatMessagesLogic.getAllowedMessagesPaginated( currentAccount.getAccount(), chatId, latestMessageId, maxSize );
        List<MessageToFrontend> frontendMessages = getMessages
                .map( l -> l.stream().map( MessageToFrontend::new ).collect( Collectors.toList() ) )
                .orElse( new ArrayList<>() );
        Collections.sort( frontendMessages );
        return ResponseEntity.ok( frontendMessages );
    }



    @DeleteMapping( value = "/{messageId}" )
    public ResponseEntity<Void> deleteMessage( @PathVariable() long messageId, @PathVariable() long chatId ) {
        boolean succeeded = chatMessagesLogic.deleteMessageIfAllowed( currentAccount.getAccount(), messageId, chatId );

        if(succeeded)
            chatSubscriptionWebsocket.notifyAllSessionsOfDeletedMessage( messageId,  chatId);

        return succeeded ? ResponseEntity.status( HttpStatus.NO_CONTENT ).build() : ResponseEntity.status( HttpStatus.NOT_FOUND ).build();
    }

    @PostMapping()
    public ResponseEntity<Void> postMessage( @PathVariable() long chatId, @RequestBody MessageFromFrontend messageFromFrontend ) {
        Optional<Chat> chat = chatRepository.findById( chatId );

        Instant selfDestructionTime = messageFromFrontend.getSelfDestructionDurationSecs() != null ? Instant.now().plusSeconds(messageFromFrontend.getSelfDestructionDurationSecs()) : null;
        Optional<Message> message = chat.map( c -> new Message(
                0,
                currentAccount.getAccount(),
                c,
                messageFromFrontend.getValue(),
                messageFromFrontend.getAttachedFiles().stream().map(fileFromFe -> new AttachedFile(fileFromFe.fileName(), fileFromFe.encodedFileContent())).toList(),
                Instant.now(),
                selfDestructionTime ) );

        boolean succeeded = message.map( m -> chatMessagesLogic.saveMessageToChatIfAllowed( currentAccount.getAccount(), chatId, m ) ).orElse( false );

        if ( succeeded )
            this.chatSubscriptionWebsocket.notifyAllSessions( message.get(), chatId );

        return succeeded ? ResponseEntity.status( HttpStatus.NO_CONTENT ).build() : ResponseEntity.status( HttpStatus.NOT_FOUND ).build();
    }

    @PutMapping("/{messageId}")
    public ResponseEntity<Void> updateMessage( @PathVariable() long chatId, @PathVariable() long messageId, @RequestBody UpdateMessageRequest request ) {
        Message updatedMessage = chatMessagesLogic.updateMessage( currentAccount.getAccount(), chatId, messageId, request.value() );
        this.chatSubscriptionWebsocket.notifyAllSessionsOfUpdatedMessage( updatedMessage, chatId );

        return ResponseEntity.status( HttpStatus.NO_CONTENT ).build();
    }

    @GetMapping( "/subscription" )
    public ResponseEntity<WebsocketSessionKey> getSubscriptionSessionKey( @PathVariable( "chatId" ) long chatId ) {
        Optional<Chat> chat = chatRepository.findById( chatId );

        boolean isAllowed = chat.map( c -> c.isAccountActiveMember( currentAccount.getAccount() ) ).orElse( false );

        if ( !isAllowed )
            throw new UnauthorizedException( "Not authorized to read from this chat or chat doesn't exist" );


        return ResponseEntity.ok( webSocketSessionLogic.createSessionKey( chatId, currentAccount.getAccount() ) );
    }


}