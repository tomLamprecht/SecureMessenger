package de.thws.securemessenger.repositories;

import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.ChatToAccount;
import io.micrometer.observation.ObservationFilter;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ChatToAccountRepository extends JpaRepository<ChatToAccount, Long> {
    ObservationFilter findChatToAccountByIdAndAccount(long chatId, Account account);

    // TODO refactor
    //Optional<ChatToAccount> findChatToUserByChatIdAndUserId(long userId, long chatId );

}
