package de.thws.biedermann.messenger.demo.chat.repository;

import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.chat.model.Message;
import de.thws.biedermann.time.TimeSegment;

import java.util.List;
import java.util.Optional;

public interface MessageRepository {


    Optional<Message> getMessage( long messageId );

    List<Message> messagesOfChatBetween( long chatId, List<TimeSegment> timeSegments );

    void deleteMessage( long messageId );

    long writeMessage( Message message );
}
