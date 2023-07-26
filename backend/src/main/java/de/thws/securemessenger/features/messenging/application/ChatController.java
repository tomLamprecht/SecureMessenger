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
@RequestMapping("/chat")
public class ChatController {

    @Autowired
    private CurrentAccount currentAccount;
    @Autowired
    private ChatSubscriptionPublisher chatSubscriptionPublisher;
    @Autowired
    private UserChatLogic userChatLogic;


    @GetMapping("/{chat_id}")
    public ResponseEntity<List<Message>> getMessages(@PathVariable("chat_id") long chatId) {
        return ResponseEntity.of(userChatLogic.getAllowedMessages(currentAccount.getAccount(), chatId));
    }


    @DeleteMapping("/messages/{message_id}")
    public ResponseEntity<Void> deleteMessage(@PathVariable("message_id") long messageId) {
        boolean succeeded = userChatLogic.deleteMessageIfAllowed(currentAccount.getAccount(), messageId);

        return succeeded ? ResponseEntity.status(HttpStatus.NO_CONTENT).build() : ResponseEntity.status(HttpStatus.NOT_FOUND).build();
    }

    @PostMapping("/{chat_id}")
    public ResponseEntity<Void> postMessage(@PathVariable("chat_id") long chatId, Message message) {
        boolean succeeded = userChatLogic.saveMessageToChatIfAllowed(currentAccount.getAccount(), chatId, message);

        if (succeeded)
            this.chatSubscriptionPublisher.notifyChatSubscriptions(chatId, message);

        return succeeded ? ResponseEntity.status(HttpStatus.NO_CONTENT).build() : ResponseEntity.status(HttpStatus.NOT_FOUND).build();
    }


    @GetMapping("/{chat_id}/sub")
    public Flux<Message> getMessageStream(@PathVariable("chat_id") long chatId) {
        Sinks.Many<Message> sink = Sinks.many().unicast().onBackpressureBuffer();
        Flux<Message> hotFlux = sink.asFlux().publish().autoConnect();

        var chatSubscriber = ChatSubscriber.of(chatId, sink, hotFlux);

        this.chatSubscriptionPublisher.subscribe(chatSubscriber);

        hotFlux.doFinally(s -> chatSubscriptionPublisher.unsubscribe(chatSubscriber));

        return hotFlux;
    }


}