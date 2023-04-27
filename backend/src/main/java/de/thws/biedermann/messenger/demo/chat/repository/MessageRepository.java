package de.thws.biedermann.messenger.demo.chat.repository;

import de.thws.biedermann.messenger.demo.chat.model.Message;
import de.thws.biedermann.messenger.demo.shared.model.TimeSegment;

import java.util.List;
import java.util.Optional;

public interface MessageRepository {

    Optional<Message> getMessage( long messageId );

    Optional<Message> writeMessage( Message message );

    boolean deleteMessage( long messageId );

    List<Message> messagesOfChatBetween( long chatId, List<TimeSegment> timeSegments );
}
