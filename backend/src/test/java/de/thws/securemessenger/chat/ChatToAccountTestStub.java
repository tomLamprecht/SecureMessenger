package de.thws.securemessenger.chat;

import de.thws.securemessenger.model.ChatToAccount;
import de.thws.securemessenger.repositories.ChatToAccountRepository;
import de.thws.securemessenger.features.messenging.model.TimeSegment;

import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicLong;

public class ChatToAccountTestStub implements ChatToAccountRepository {

    private final Map<Long, ChatToAccount> map = new HashMap<>( );
    private final AtomicLong counter = new AtomicLong(1);

    // mock
    @Override
    public List<TimeSegment> findByUserIdAndChatId(long userId, long chatId ) {
        return List.of( new TimeSegment( Instant.MIN, Instant.MAX ) );
    }

    @Override
    public long createChatToUser( ChatToAccount chatToAccount) {
        ChatToAccount result = new ChatToAccount( counter.get(), chatToAccount.account(), chatToAccount.chat(), chatToAccount.key(), chatToAccount.isAdmin(), chatToAccount.joinedAt(), chatToAccount.leftAt());
        map.put( counter.getAndIncrement(), result );
        return result.id();
    }

    @Override
    public Optional<ChatToAccount> readChatToUser(long id ) {
        return Optional.ofNullable( map.get( id ));
    }

    @Override
    public Optional<ChatToAccount> findChatToUserByChatIdAndUserId(long userId, long chatId ) {
        return Optional.empty( );
    }


}
