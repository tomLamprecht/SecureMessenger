package de.thws.securemessenger.features.messenging.application;

import de.thws.securemessenger.features.authorization.application.CurrentAccount;
import de.thws.securemessenger.features.messenging.logic.ChatLogic;
import de.thws.securemessenger.features.messenging.logic.ChatMemberLogic;
import de.thws.securemessenger.features.messenging.model.AccountToChat;
import de.thws.securemessenger.features.messenging.model.CreateNewChatRequest;
import de.thws.securemessenger.model.Chat;
import de.thws.securemessenger.model.ChatToAccount;
import feign.Body;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.server.WebServerException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;


@RestController
@RequestMapping("/chats")
public class ChatController {

    private final CurrentAccount currentAccount;
    private final ChatLogic chatLogic;
    private final ChatMemberLogic chatMemberLogic;

    @Autowired
    public ChatController(CurrentAccount currentAccount, ChatLogic chatLogic, ChatMemberLogic chatMemberLogic) {
        this.currentAccount = currentAccount;
        this.chatLogic = chatLogic;
        this.chatMemberLogic = chatMemberLogic;
    }

    @PostMapping
    public ResponseEntity<Long> createChat(@RequestBody CreateNewChatRequest request) throws URISyntaxException {
        long newChatId = chatLogic.createNewChat(request, currentAccount.getAccount());
        return ResponseEntity.created(new URI("/chats/" + newChatId)).body(newChatId);
    }

    @GetMapping
    public ResponseEntity<List<Chat>> getChatsOfUser( ) {
        List<Chat> resultChatOverview = currentAccount.getAccount().chatToAccounts().stream().map(ChatToAccount::chat).toList();
        return ResponseEntity.ok().body( resultChatOverview );
    }

    @GetMapping("/{chatId:[0-9]+}")
    public ResponseEntity<ChatToAccount> getChatToUser(@PathVariable( "chatId" ) long chatId ) {
        // todo: check, weather the user has access to the chat
        return currentAccount.getAccount().chatToAccounts().stream().filter(chatToAccount -> chatToAccount.chat().id() == chatId).findAny()
            .map( ResponseEntity::ok )
            .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping(value= "/{chatId}/symmetric-key", produces = "text/plain")
    public ResponseEntity<String> getOwnSymmetricKeyOfChat(@PathVariable long chatId) {
        return ResponseEntity.of(chatLogic.getSymmetricKey(currentAccount.getAccount(), chatId));
    }

    @PostMapping("/{chatId:[0-9]+}/accounts")
    public ResponseEntity<Long> addAccountsToGroup(@PathVariable long chatId, List<AccountToChat> request) throws URISyntaxException {
        chatMemberLogic.addAccountsToChat(chatId, request, currentAccount.getAccount());
        return ResponseEntity.created(new URI("/chats/" + chatId + "/accounts")).build();
    }

    @DeleteMapping("/{chatId:[0-9]+}/accounts/{accountId:[0-9]+}")
    public ResponseEntity<Void> removeAccountFromChat(@PathVariable long chatId, @PathVariable long accountId) {
        chatMemberLogic.deleteAccountFromChat(chatId, accountId, currentAccount.getAccount());
        return ResponseEntity.noContent().build();
    }
}
