package de.thws.securemessenger.repositories;

import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.Chat;
import de.thws.securemessenger.model.ChatToAccount;
import io.micrometer.observation.ObservationFilter;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ChatToAccountRepository extends JpaRepository<ChatToAccount, Long> {
    Optional<ChatToAccount> findChatToAccountByChatIdAndAccount(long chatId, Account account);
    Optional<ChatToAccount> findChatToAccountByChatAndAccount( Chat chat, Account account);
    Optional<ChatToAccount> findByChatIdAndAccount_Id(long chatId, long AccountId);
    List<ChatToAccount> findAllByChat(Chat chat);
    List<ChatToAccount> findAllByChatId(long chatId);

    List<ChatToAccount> findAllByChat_IdAndIsAdminEquals(long chatId, boolean isAdmin);


}
