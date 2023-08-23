package de.thws.securemessenger.repositories;

import de.thws.securemessenger.model.Account;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.Set;

@Repository
public interface AccountRepository extends JpaRepository<Account, Long> {

    @Query("SELECT a FROM Account a WHERE a.id IN :ids")
    List<Account> findAccountsById(@Param("ids") List<Long> ids);
    Optional<Account> findAccountByPublicKey(String publicKey);
    Optional<Account> findAccountById(long accountId);
    Optional<Account> findAccountByUsername(String username);

    @Query("SELECT a FROM Account a JOIN ChatToAccount cta ON a.id = cta.account.id WHERE cta.chat.id = :chatId")
    List<Account> findAllByChatId(long chatId);

}
