package de.thws.biedermann.messenger.demo.authorization.adapter.persistence;

import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.chat.repository.ChatToUserRepository;
import de.thws.biedermann.time.TimeSegment;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class ChatToUserRepositoryDB implements ChatToUserRepository {
    @Override
    public List<TimeSegment> getChatAccessTimeSegmentsOfUser( User user, long chatId ) {
        return null;
    }
}
