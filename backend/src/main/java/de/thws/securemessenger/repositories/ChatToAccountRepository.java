package de.thws.securemessenger.repositories;

import de.thws.securemessenger.model.ChatToAccount;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ChatToAccountRepository extends JpaRepository<ChatToAccount, Long> {

    // TODO refactor
    //Optional<ChatToAccount> findChatToUserByChatIdAndUserId(long userId, long chatId );

}
