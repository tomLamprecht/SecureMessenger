package de.thws.securemessenger.repositories;

import de.thws.securemessenger.model.Account;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface AccountRepository extends JpaRepository<Account, Long> {

    Optional<Account> findAccountByPublicKey(String publicKey);
    Optional<Account> findAccountById(long accountId);
    Optional<Account> findAccountByUsername(String username);

}
