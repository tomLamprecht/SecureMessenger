package de.thws.securemessenger.features.messenging.application;

import de.thws.securemessenger.features.authorization.application.CurrentAccount;
import de.thws.securemessenger.features.messenging.logic.UserChatLogic;
import de.thws.securemessenger.repositories.ChatToAccountRepository;
import de.thws.securemessenger.model.Chat;
import de.thws.securemessenger.model.ChatToAccount;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/chats")
public class ChatController {

    @Autowired
    private CurrentAccount currentAccount;
    @Autowired
    private UserChatLogic userChatLogic;
    @Autowired
    private ChatToAccountRepository chatToAccountRepository;

    @PostMapping
    public ResponseEntity<Void> postChatToUser(ChatToAccount chatToAccount) {
        if (!userChatLogic.userCanCreateChatWithOtherUser(currentAccount.getAccount(), chatToAccount.account())) {
            return ResponseEntity.notFound().build();
        }

        Optional<ChatToAccount> resultChatToUser = userChatLogic.createChatToUserAndReturnResult(chatToAccount);

        return resultChatToUser
                .map( ChatToAccount::chat )
                .map( id -> URI.create( "/chats/" + id) )
                .map( ResponseEntity::created )
                .orElse( ResponseEntity.internalServerError() )
                .build();
    }

    @GetMapping
    public ResponseEntity<List<Chat>> getChatsOfUser( ) {
        List<Chat> resultChatOverview = currentAccount.getAccount().chatToAccounts().stream().map(ChatToAccount::chat).toList();
        return ResponseEntity.ok().body( resultChatOverview );
    }

    @GetMapping("/{chatId:[0-9]+}/my-chat")
    public ResponseEntity<ChatToAccount> getChatToUser(@PathVariable( "chatId" ) long chatId ) {
        return currentAccount.getAccount().chatToAccounts().stream().filter(chatToAccount -> chatToAccount.chat().id() == chatId).findAny()
            .map( ResponseEntity::ok )
            .orElseGet(() -> ResponseEntity.notFound().build());
    }

}
