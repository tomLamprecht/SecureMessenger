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
    public List<TimeSegment> getChatAccessTimeSegmentsOfUser( long userId, long chatId ) {
        return null;
    }

    @Override
    public long createChatToUser( ChatToUser chatToUser ) {
        return 0;
    }

    @Override
    public Optional<ChatToUser> readChatToUser( long id ) {
        return Optional.empty( );
    }

    @Override
    public Optional<ChatToUser> readChatToUserByChatIdAndUserId( long userId, long chatId ) {
        return Optional.empty( );
    }
}
