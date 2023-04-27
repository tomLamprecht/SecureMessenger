package de.thws.biedermann.messenger.demo.chat.adapter;

import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.chat.model.ChatToUser;
import de.thws.biedermann.messenger.demo.chat.repository.ChatToUserRepository;
import de.thws.biedermann.messenger.demo.shared.model.TimeSegment;

import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicLong;

public class ChatToUserTestStub implements ChatToUserRepository {

    private final Map<Long, ChatToUser> map = new HashMap<>( );
    private final AtomicLong counter = new AtomicLong(1);

    // mock
    @Override
    public List<TimeSegment> getChatAccessTimeSegmentsOfUser( User user, long chatId ) {
        return List.of( new TimeSegment( Instant.MIN, Instant.MAX ) );
    }

    @Override
    public Optional<ChatToUser> createChatToUser( ChatToUser chatToUser ) {
        ChatToUser result = new ChatToUser( counter.get(), chatToUser.userId(), chatToUser.chatId(), chatToUser.key(), chatToUser.isAdmin(), chatToUser.joinedAt(), chatToUser.leftAt());
        map.put( counter.getAndIncrement(), result );
        return Optional.of( result );
    }

    @Override
    public Optional<ChatToUser> readChatToUser( long id ) {
        return Optional.ofNullable( map.get( id ));
    }


}
