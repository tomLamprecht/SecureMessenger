package de.thws.securemessenger.features.messenging.application;

import de.thws.securemessenger.features.authorization.application.CurrentAccount;
import de.thws.securemessenger.features.messenging.logic.ChatSubscriber;
import de.thws.securemessenger.features.messenging.logic.UserChatLogic;
import de.thws.securemessenger.model.Message;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Sinks;

import java.util.List;

@RestController
@RequestMapping("/chats/{chatId}/messages")
public class MessageController {

    @Autowired
    private CurrentAccount currentAccount;
    @Autowired
    private ChatSubscriptionPublisher chatSubscriptionPublisher;
    @Autowired
    private UserChatLogic userChatLogic;


    @GetMapping()
    public ResponseEntity<List<Message>> getMessages(@PathVariable() long chatId) {
        return ResponseEntity.of(userChatLogic.getAllowedMessages(currentAccount.getAccount(), chatId));
    }


    @DeleteMapping("/{messageId}")
    public ResponseEntity<Void> deleteMessage(@PathVariable() long messageId) {
        boolean succeeded = userChatLogic.deleteMessageIfAllowed(currentAccount.getAccount(), messageId);

        return succeeded ? ResponseEntity.status(HttpStatus.NO_CONTENT).build() : ResponseEntity.status(HttpStatus.NOT_FOUND).build();
    }

    @PostMapping()
    public ResponseEntity<Void> postMessage(@PathVariable() long chatId, Message message) {
        // todo: user should not be able to set the timestamp
        boolean succeeded = userChatLogic.saveMessageToChatIfAllowed(currentAccount.getAccount(), chatId, message);

        if (succeeded)
            this.chatSubscriptionPublisher.notifyChatSubscriptions(chatId, message);

        return succeeded ? ResponseEntity.status(HttpStatus.NO_CONTENT).build() : ResponseEntity.status(HttpStatus.NOT_FOUND).build();
    }


    @GetMapping("/subscription")
    public Flux<Message> getMessageStream(@PathVariable("chatId") long chatId) {
        Sinks.Many<Message> sink = Sinks.many().unicast().onBackpressureBuffer();
        Flux<Message> hotFlux = sink.asFlux().publish().autoConnect();

        var chatSubscriber = ChatSubscriber.of(chatId, sink, hotFlux);

        this.chatSubscriptionPublisher.subscribe(chatSubscriber);

        hotFlux.doFinally(s -> chatSubscriptionPublisher.unsubscribe(chatSubscriber));

        return hotFlux;
    }


}