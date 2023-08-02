package de.thws.securemessenger.repositories;

import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.Friendship;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FriendshipRepository extends JpaRepository<Friendship, Long> {
    Optional<Friendship> findFriendshipByFromAccountAndToAccount(Account fromAccount, Account toAccount);
    List<Friendship> findAllByFromAccountId(long fromAccountId);
    List<Friendship> findAllByFromAccountIdAndAcceptedEquals(long fromAccountId, boolean accepted);
    List<Friendship> findAllByToAccountId(long toAccountId);
    List<Friendship> findAllByToAccountIdAndAcceptedEquals(long toAccountId, boolean accepted);
}
