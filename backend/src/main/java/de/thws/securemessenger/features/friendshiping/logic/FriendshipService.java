package de.thws.securemessenger.features.friendshiping.logic;

import de.thws.securemessenger.features.friendshiping.model.FriendshipResponse;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.ApiExceptions.BadRequestException;
import de.thws.securemessenger.model.Friendship;
import de.thws.securemessenger.repositories.AccountRepository;
import de.thws.securemessenger.repositories.FriendshipRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;


@Service
public class FriendshipService {

    private final FriendshipRepository friendshipRepository;
    private final AccountRepository accountRepository;

    @Autowired
    public FriendshipService(FriendshipRepository friendshipRepository, AccountRepository accountRepository) {
        this.friendshipRepository = friendshipRepository;
        this.accountRepository = accountRepository;
    }

    public Optional<Long> handleFriendshipRequest(Account currentAccount, long toAccountId) {
        Optional<Account> toAccount = accountRepository.findById(toAccountId);

        if (toAccount.isEmpty()){
            return Optional.empty();
        }

        validateUserHasNotPerformedInvitationBefore(currentAccount, toAccount.get());

        Optional<Friendship> existingFriendshipRequest;

        existingFriendshipRequest = friendshipRepository.findFriendshipByFromAccountAndToAccount(toAccount.get(), currentAccount);

        if (existingFriendshipRequest.isEmpty()) {
            Friendship newFriendship = new Friendship(0, currentAccount, toAccount.get(), false);
            friendshipRepository.save(newFriendship);
            return Optional.of(newFriendship.id());
        }

        existingFriendshipRequest.get().setAccepted(true);
        friendshipRepository.save(existingFriendshipRequest.get());
        return Optional.of(existingFriendshipRequest.get().id());
    }

    private void validateUserHasNotPerformedInvitationBefore(Account currentAccount, Account toAccount) {
        Optional<Friendship> existingFriendshipRequest = friendshipRepository.findFriendshipByFromAccountAndToAccount(currentAccount, toAccount);

        if (existingFriendshipRequest.isPresent()) {
            throw new BadRequestException("Friendship request already exists");
        }
    }

    public Optional<Friendship> getFriendshipWith(Account currentAccount, long toAccountId) {
        Optional<Account> toAccount = accountRepository.findById(toAccountId);
        return toAccount.flatMap(currentAccount::friendshipWith);
    }

    public List<FriendshipResponse> getAllAcceptedFriendships(Account currentAccount) {
        return friendshipRepository.findAllFriendshipBiDirectional(currentAccount.id()).stream()
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

    public boolean deleteFriendshipBetween(Account account, long friendAccountId) {
        int deleteCount = friendshipRepository.deleteFriendshipBiDirectional(account.id(), friendAccountId);
        return deleteCount > 0;
    }
}

