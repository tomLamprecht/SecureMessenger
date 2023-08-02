package de.thws.securemessenger.repositories;

import de.thws.securemessenger.model.Account;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AccountRepository extends JpaRepository<Account, Long> {

    Account findAccountByPublicKey(String publicKey);
    Account findAccountById(long accountId);
    Account findAccountByUsername(String username);

}
