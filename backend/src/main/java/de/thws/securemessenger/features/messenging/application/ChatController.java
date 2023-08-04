package de.thws.securemessenger.features.messenging.application;

import de.thws.securemessenger.features.authorization.application.CurrentAccount;
import de.thws.securemessenger.features.messenging.logic.UserChatLogic;
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
    private final UserChatLogic userChatLogic;

    @Autowired
    public ChatController(CurrentAccount currentAccount, UserChatLogic userChatLogic) {
        this.currentAccount = currentAccount;
        this.userChatLogic = userChatLogic;
    }

    @PostMapping
    public ResponseEntity<Long> createChat(CreateNewChatRequest request) throws URISyntaxException {
        long newChatId = userChatLogic.createNewChat(request, currentAccount.getAccount());
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

    @GetMapping("/{chatId}/symmetric-key")
    public ResponseEntity<String> getOwnSymmetricKeyOfChat(@PathVariable long chatId) {
        return ResponseEntity.of(userChatLogic.getSymmetricKey(currentAccount.getAccount(), chatId));
    }

}
