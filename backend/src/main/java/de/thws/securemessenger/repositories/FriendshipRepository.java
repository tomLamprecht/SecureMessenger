package de.thws.securemessenger.repositories;

import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.Friendship;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
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

    @Query("SELECT f FROM Friendship f " +
            "WHERE f.fromAccount.id = :accountId OR f.toAccount.id = :accountId")
    List<Friendship> findAllFriendshipBiDirectional(long accountId);

    @Modifying
    @Transactional
    @Query("DELETE FROM Friendship f " +
            "WHERE (f.fromAccount.id = :accountId1 AND f.toAccount.id = :accountId2) " +
            "OR (f.fromAccount.id = :accountId2 AND f.toAccount.id = :accountId1)")
    int deleteFriendshipBiDirectional(long accountId1, long accountId2);
}
