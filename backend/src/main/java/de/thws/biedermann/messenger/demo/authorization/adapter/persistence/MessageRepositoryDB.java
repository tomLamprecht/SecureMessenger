package de.thws.biedermann.messenger.demo.authorization.adapter.persistence;

import de.thws.biedermann.messenger.demo.chat.model.Message;
import de.thws.biedermann.messenger.demo.chat.repository.MessageRepository;
import de.thws.biedermann.messenger.demo.shared.model.TimeSegment;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
public class MessageRepositoryDB implements MessageRepository {
    @Override
    public Optional<Message> getMessage( long messageId ) {
        return Optional.empty( );
    }

    @Override
    public List<Message> messagesOfChatBetween( long chatId, List<TimeSegment> timeSegments ) {
        return null;
    }

    @Override
    public boolean deleteMessage( long messageId ) {
        return false;
    }

    @Override
    public Optional<Message> writeMessage( Message message ) {
        return Optional.empty();
    }
}
