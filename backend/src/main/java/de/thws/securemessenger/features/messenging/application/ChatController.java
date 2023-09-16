package de.thws.securemessenger.features.messenging.application;

import de.thws.securemessenger.features.authorization.application.CurrentAccount;
import de.thws.securemessenger.features.messenging.logic.ChatLogic;
import de.thws.securemessenger.features.messenging.logic.ChatMemberLogic;
import de.thws.securemessenger.features.messenging.model.*;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.Chat;
import de.thws.securemessenger.model.ChatToAccount;
import de.thws.securemessenger.repositories.ChatToAccountRepository;
import org.hibernate.Hibernate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.transaction.annotation.Transactional;


import java.net.URI;
import java.net.URISyntaxException;
import java.util.List;


@RestController
@RequestMapping("/chats")
public class ChatController {

    private final CurrentAccount currentAccount;
    private final ChatLogic chatLogic;
    private final ChatMemberLogic chatMemberLogic;
    private final ChatToAccountRepository chatToAccountRepository;

    @Autowired
    public ChatController(CurrentAccount currentAccount, ChatLogic chatLogic, ChatMemberLogic chatMemberLogic, ChatToAccountRepository chatToAccountRepository) {
        this.currentAccount = currentAccount;
        this.chatLogic = chatLogic;
        this.chatMemberLogic = chatMemberLogic;
        this.chatToAccountRepository = chatToAccountRepository;
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

    @PutMapping("{chatId}/update-group-pic")
    public ResponseEntity<Void> updateChatGroupPic(@PathVariable() long chatId, @RequestBody String encodedGroupPic) {
        chatLogic.updateChatGroupPic(chatId, currentAccount.getAccount(), extractTextAfterColon( encodedGroupPic ) );
        return ResponseEntity.ok().build();
    }

    public static String extractTextAfterColon(String inputText) {
        String cleanedText = inputText.replaceAll("[{}\"]", "");

        String[] parts = cleanedText.split(":");

        if (parts.length >= 2) {
            return parts[1].trim();
        } else {
            return "";
        }
    }


    @GetMapping
    public ResponseEntity<List<Chat>> getChatsOfUser( ) {
        var listToAccounts = currentAccount.getAccount();
        List<Chat> resultChatOverview = listToAccounts.chatToAccounts().stream().map(ChatToAccount::chat).toList();
        return ResponseEntity.ok().body( resultChatOverview );
    }

    @GetMapping("/{chatId}")
    public ResponseEntity<ChatToAccountResponse> getChatToUser(@PathVariable( "chatId" ) long chatId) {
        var chatToAccount = chatToAccountRepository.findChatToAccountByChatIdAndAccount( chatId, currentAccount.getAccount() );
        if (chatToAccount.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(chatToAccount.map(ChatToAccountResponse::new).get());
    }

    @GetMapping(value= "/{chatId}/symmetric-key")
    public ResponseEntity<ChatKey> getOwnSymmetricKeyOfChat(@PathVariable long chatId) {
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

    @DeleteMapping("/{chatId}/delete-group-pic")
    public ResponseEntity<Void> deleteChatGroupPic(@PathVariable long chatId) {
        chatLogic.deleteChatGroupPic(chatId);
        return ResponseEntity.noContent().build();
    }
}
