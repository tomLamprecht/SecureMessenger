package de.thws.biedermann.messenger.demo.authorization.adapter.persistence;

import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.chat.model.ChatToUser;
import de.thws.biedermann.messenger.demo.chat.repository.ChatToUserRepository;
import de.thws.biedermann.messenger.demo.shared.model.TimeSegment;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
public class ChatToUserRepositoryDB implements ChatToUserRepository {
    @Override
    public List<TimeSegment> getChatAccessTimeSegmentsOfUser( User user, long chatId ) {
        return null;
    }

    @Override
    public Optional<ChatToUser> createChatToUser( ChatToUser chatToUser ) {
        return Optional.empty( );
    }

    @Override
    public Optional<ChatToUser> readChatToUser( long id ) {
        return Optional.empty( );
    }
}