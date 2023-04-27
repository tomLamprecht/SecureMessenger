package de.thws.biedermann.messenger.demo.chat.adapter;

import de.thws.biedermann.messenger.demo.chat.model.Message;
import de.thws.biedermann.messenger.demo.chat.repository.MessageRepository;
import de.thws.biedermann.messenger.demo.shared.model.TimeSegment;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicLong;

public class MessageTestStub implements MessageRepository {

    private final Map<Long, Message> messageMap = new HashMap<>();
    private final AtomicLong counter = new AtomicLong(1);

    @Override
    public Optional<Message> getMessage( long messageId ) {
        return Optional.ofNullable( messageMap.get( messageId ) );
    }

    @Override
    public List<Message> messagesOfChatBetween( long chatId, List<TimeSegment> timeSegments ) {
        return messageMap.values().stream().filter( m -> m.chatId() == chatId ).toList();
    }

    @Override
    public boolean deleteMessage( long messageId ) {
        return messageMap.remove( messageId ) != null;
    }

    @Override
    public Optional<Message> writeMessage( Message message ) {
        messageMap.put( counter.get(), message );
        Message result = new Message( counter.getAndIncrement(), message.fromUser(), message.chatId(), message.value(), message.timeStamp() );
        return Optional.of( result );
    }
}
