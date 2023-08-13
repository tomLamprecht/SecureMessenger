package de.thws.securemessenger.features.friendshiping.logic;

import de.thws.securemessenger.features.friendshiping.model.FriendshipResponse;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.Friendship;
import de.thws.securemessenger.model.response.FriendshipResponse;
import de.thws.securemessenger.repositories.AccountRepository;
import de.thws.securemessenger.repositories.FriendshipRepository;
import jakarta.persistence.EntityManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;


@Service
public class FriendshipService {

    private final FriendshipRepository friendshipRepository;
    private final AccountRepository accountRepository;
    private final EntityManager entityManager;

    @Autowired
    public FriendshipService(FriendshipRepository friendshipRepository, AccountRepository accountRepository, EntityManager entityManager) {
        this.friendshipRepository = friendshipRepository;
        this.accountRepository = accountRepository;
        this.entityManager = entityManager;
    }

    public Optional<Long> handleFriendshipRequest(Account currentAccount, long toAccountId) {
        Optional<Account> toAccount = accountRepository.findById(toAccountId);

        if (toAccount.isEmpty()){
            return Optional.empty();
        }

        Optional<Friendship> existingFriendshipRequest = friendshipRepository.findFriendshipByFromAccountAndToAccount(toAccount.get(), currentAccount);

        if (existingFriendshipRequest.isEmpty()) {
            friendshipRepository.findFriendshipByFromAccountAndToAccount(currentAccount, toAccount.get());
        }

        if (existingFriendshipRequest.isEmpty()) {
            Friendship newFriendship = new Friendship(0, currentAccount, toAccount.get(), false);
            friendshipRepository.save(newFriendship);
            return Optional.of(newFriendship.id());
        }

        existingFriendshipRequest.get().setAccepted(true);
        friendshipRepository.save(existingFriendshipRequest.get());
        return Optional.of(existingFriendshipRequest.get().id());
    }

    public Optional<Friendship> getFriendshipWith(Account currentAccount, long toAccountId) {
        Optional<Account> toAccount = accountRepository.findById(toAccountId);
        return toAccount.flatMap(currentAccount::friendshipWith);
    }

    public List<FriendshipResponse> getAllAcceptedFriendships(Account currentAccount) {
        return currentAccount
                .friendships()
                .stream()
                .filter(Friendship::accepted)
                .map(FriendshipResponse::new)
                .toList();
    }

    public List<FriendshipResponse> getAllIncomingFriendshipRequests(Account currentAccount, boolean showOnlyPending){
        if (showOnlyPending){
            return friendshipRepository.findAllByToAccountIdAndAcceptedEquals(currentAccount.id(), false).stream().map(FriendshipResponse::new).toList();
        }
        return friendshipRepository.findAllByToAccountId(currentAccount.id()).stream().map(FriendshipResponse::new).toList();
    }

    public List<Friendship> getAllOutgoingFriendshipRequests(Account currentAccount, boolean showOnlyPending){
        if (showOnlyPending){
            return friendshipRepository.findAllByFromAccountIdAndAcceptedEquals(currentAccount.id(), false);
        }
        return friendshipRepository.findAllByFromAccountId(currentAccount.id());
    }

    public boolean deleteFriendshipRequest(Account currentAccount, long toAccountId) {
        return accountRepository
                .findById(toAccountId)
                .flatMap(currentAccount::friendshipWith)
                .map(friendship -> {
                    entityManager.remove(friendship);
                    return true;
                })
                .orElse(false);
    }
}

