package de.thws.biedermann.messenger.demo.chat.adapter.persistence;

import de.thws.biedermann.messenger.demo.chat.model.Friendship;
import de.thws.biedermann.messenger.demo.chat.repository.FriendshipRepository;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class FriendshipRepositoryImpl implements FriendshipRepository {
    @Override
    public Optional<Friendship> readFriendship( long fromUserId, long toUserId ) {
        return Optional.empty( );
    }
}
