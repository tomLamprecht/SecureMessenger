package de.thws.securemessenger.features.messenging.application;

import de.thws.securemessenger.features.authorization.application.CurrentAccount;
import de.thws.securemessenger.features.messenging.logic.ChatLogic;
import de.thws.securemessenger.features.messenging.logic.ChatMemberLogic;
import de.thws.securemessenger.features.messenging.model.AccountResponse;
import de.thws.securemessenger.features.messenging.model.AccountToChat;
import de.thws.securemessenger.features.messenging.model.ChatToAccountResponse;
import de.thws.securemessenger.features.messenging.model.CreateNewChatRequest;
import de.thws.securemessenger.model.Chat;
import de.thws.securemessenger.model.ChatToAccount;
import org.springframework.beans.factory.annotation.Autowired;
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

    @PutMapping("{chatId}/accounts/{accountId}/admin")
    public ResponseEntity<Void> updateAdminRights(@PathVariable() long chatId, @PathVariable() long accountId, @RequestParam(defaultValue = "false") boolean isAdmin) {
        chatLogic.addAdminRights(chatId, currentAccount.getAccount(), accountId, isAdmin);
        return ResponseEntity.noContent().build();
    }

    @GetMapping
    public ResponseEntity<List<Chat>> getChatsOfUser( ) {
        List<Chat> resultChatOverview = currentAccount.getAccount().chatToAccounts().stream().map(ChatToAccount::chat).toList();
        return ResponseEntity.ok().body( resultChatOverview );
    }

    @GetMapping("/{chatId}")
    public ResponseEntity<ChatToAccountResponse> getChatToUser(@PathVariable( "chatId" ) long chatId) {
        var chatToAccount = currentAccount.getAccount().chatToAccounts().stream().filter(entry -> entry.chat().id() == chatId).findAny();
        if (chatToAccount.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(chatToAccount.map(ChatToAccountResponse::new).get());
    }

    @GetMapping(value= "/{chatId}/symmetric-key", produces = "text/plain")
    public ResponseEntity<String> getOwnSymmetricKeyOfChat(@PathVariable long chatId) {
        return ResponseEntity.of(chatLogic.getSymmetricKey(currentAccount.getAccount(), chatId));
    }

    @PostMapping("/{chatId}/accounts")
    public ResponseEntity<Long> addAccountsToGroup(@PathVariable long chatId, @RequestBody List<AccountToChat> request) throws URISyntaxException {
        chatMemberLogic.addAccountsToChat(chatId, request, currentAccount.getAccount());
        return ResponseEntity.created(new URI("/chats/" + chatId + "/accounts")).build();
    }

    @GetMapping("/{chatId}/accounts")
    public ResponseEntity<List<AccountResponse>> getAllAccountsInChat(@PathVariable long chatId) {
        return ResponseEntity.ok(chatMemberLogic.getAllAccountsInChat(chatId, currentAccount.getAccount()));
    }

    @GetMapping("/{chatId}/chat-to-accounts")
    public ResponseEntity<List<ChatToAccountResponse>> getAllChatToAccountsInChat(@PathVariable long chatId) {
        return ResponseEntity.ok(chatMemberLogic.getAllChatToAccountsInChat(chatId, currentAccount.getAccount()));
    }

    @PostMapping("/{chatId}/leave")
    public ResponseEntity<List<AccountResponse>> leaveChat(@PathVariable long chatId) {
        chatMemberLogic.leaveChat(chatId, currentAccount.getAccount());
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{chatId}")
    public ResponseEntity<Void> deleteChat(@PathVariable long chatId) {
        chatLogic.deleteChat(chatId, currentAccount.getAccount());
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{chatId}/accounts/{accountId}")
    public ResponseEntity<Void> removeAccountFromChat(@PathVariable long chatId, @PathVariable long accountId) {
        chatMemberLogic.deleteAccountFromChat(chatId, accountId, currentAccount.getAccount());
        return ResponseEntity.noContent().build();
    }
}
