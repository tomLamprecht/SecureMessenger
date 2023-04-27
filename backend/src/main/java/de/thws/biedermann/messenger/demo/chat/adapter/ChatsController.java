package de.thws.biedermann.messenger.demo.chat.adapter;

import de.thws.biedermann.messenger.demo.authorization.adapter.rest.CurrentUser;
import de.thws.biedermann.messenger.demo.chat.logic.UserChatLogic;
import de.thws.biedermann.messenger.demo.chat.model.ChatToUser;
import de.thws.biedermann.messenger.demo.chat.repository.ChatToUserRepository;
import de.thws.biedermann.messenger.demo.chat.repository.FriendshipRepository;
import de.thws.biedermann.messenger.demo.chat.repository.MessageRepository;
import de.thws.biedermann.messenger.demo.shared.repository.InstantNowRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.URI;
import java.util.Optional;

@RestController
@RequestMapping("/chats")
public class ChatsController {

    private final CurrentUser currentUser;
    private final UserChatLogic userChatLogic;

    @Autowired
    public ChatsController(
            CurrentUser currentUser,
            ChatToUserRepository chatToUserRepository,
            MessageRepository messageRepository ,
            FriendshipRepository friendshipRepository,
            InstantNowRepository instantNowRepository
    ) {
        this.currentUser = currentUser;
        this.userChatLogic = new UserChatLogic( chatToUserRepository, messageRepository, friendshipRepository, instantNowRepository );
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

}
