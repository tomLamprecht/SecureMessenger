package de.thws.biedermann.messenger.demo.chat;

import de.thws.biedermann.messenger.demo.authorization.adapter.rest.CurrentUser;
import de.thws.biedermann.messenger.demo.chat.logic.ChatsOverviewLogic;
import de.thws.biedermann.messenger.demo.chat.logic.UserChatLogic;
import de.thws.biedermann.messenger.demo.chat.model.Chat;
import de.thws.biedermann.messenger.demo.chat.model.ChatToUser;
import de.thws.biedermann.messenger.demo.chat.repository.ChatsOverviewRepository;
import de.thws.biedermann.messenger.demo.chat.repository.ChatToUserRepository;
import de.thws.biedermann.messenger.demo.chat.repository.FriendshipRepository;
import de.thws.biedermann.messenger.demo.chat.repository.MessageRepository;
import de.thws.biedermann.messenger.demo.shared.repository.InstantNowRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.Optional;

@RestController
@RequestMapping("/chats")
public class ChatsController {

    private final CurrentUser currentUser;
    private final UserChatLogic userChatLogic;
    private final ChatsOverviewLogic chatsOverviewLogic;
    private final ChatToUserRepository chatToUserRepository;

    @Autowired
    public ChatsController(
            CurrentUser currentUser,
            ChatToUserRepository chatToUserRepository,
            MessageRepository messageRepository ,
            FriendshipRepository friendshipRepository,
            InstantNowRepository instantNowRepository,
            ChatsOverviewRepository chatsOverviewRepository
    ) {
        this.currentUser = currentUser;
        this.chatToUserRepository = chatToUserRepository;
        this.userChatLogic = new UserChatLogic( chatToUserRepository, messageRepository, friendshipRepository, instantNowRepository );
        this.chatsOverviewLogic = new ChatsOverviewLogic( chatsOverviewRepository );
    }

    @PostMapping
    public ResponseEntity<Void> postChatToUser( ChatToUser chatToUser ) {
        if (!userChatLogic.userCanCreateChatWithOtherUser(currentUser.getUser().id(), chatToUser.userId())) {
            return ResponseEntity.notFound().build();
        }

        Optional<ChatToUser> resultChatToUser = userChatLogic.createChatToUserAndReturnResult( chatToUser );

        return resultChatToUser
                .map( ChatToUser::chatId )
                .map( id -> URI.create( "/chats/" + id) )
                .map( ResponseEntity::created )
                .orElse( ResponseEntity.internalServerError() )
                .build();
    }

    @GetMapping
    public ResponseEntity<List<Chat>> getChatsOfUser( ) {
        Optional<List<Chat>> resultChatOverview = chatsOverviewLogic.loadChats( currentUser.getUser() );

        return ResponseEntity
                .ok()
                .body( resultChatOverview.get() );
    }

    @GetMapping("/{chatId:[0-9]+}/my-chat")
    public ResponseEntity<ChatToUser> getChatToUser( @PathVariable( "chatId" ) long chatId ) {
        return chatToUserRepository.readChatToUserByChatIdAndUserId( currentUser.getUser().id(), chatId )
                .map( ResponseEntity::ok )
                .orElseGet( () -> ResponseEntity.notFound().build() );
    }

}
