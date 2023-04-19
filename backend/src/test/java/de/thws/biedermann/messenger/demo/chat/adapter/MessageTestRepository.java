package de.thws.biedermann.messenger.demo.chat.adapter;

import de.thws.biedermann.messenger.demo.chat.model.Message;
import de.thws.biedermann.messenger.demo.chat.repository.MessageRepository;
import de.thws.biedermann.time.TimeSegment;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicLong;

public class MessageTestRepository implements MessageRepository {

    private final Map<Long, Message> messageMap = new HashMap<>();
    private final AtomicLong counter = new AtomicLong();

    @Override
    public Optional<Message> getMessage( long messageId ) {
        return Optional.ofNullable( messageMap.get( messageId ) );
    }

    @Override
    public List<Message> messagesOfChatBetween( long chatId, List<TimeSegment> timeSegments ) {
        return messageMap.values().stream().filter( m -> m.chatId() == chatId ).toList();
    }

    @Override
    public void deleteMessage( long messageId ) {
        messageMap.remove( messageId );
    }

    @Override
    public long writeMessage( Message message ) {
        messageMap.put( counter.getAndIncrement(), message );
        return counter.get() - 1;
    }
}
