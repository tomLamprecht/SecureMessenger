package de.thws.securemessenger.features.messenging.logic;

import de.thws.securemessenger.features.messenging.model.AccountIdToEncryptedSymKey;
import de.thws.securemessenger.features.messenging.model.CreateNewChatRequest;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.ApiExceptions.BadRequestException;
import de.thws.securemessenger.model.ApiExceptions.InternalServerErrorException;
import de.thws.securemessenger.model.Chat;
import de.thws.securemessenger.model.ChatToAccount;
import de.thws.securemessenger.repositories.*;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Component
public class ChatLogic {

    private final ChatRepository chatRepository;
    private final ChatToAccountRepository chatToAccountRepository;
    private final InstantNowRepository instantNowRepository;
    private final AccountRepository accountRepository;

    public ChatLogic(ChatRepository chatRepository, ChatToAccountRepository chatToAccountRepository, InstantNowRepository instantNowRepository, AccountRepository accountRepository) {
        this.chatRepository = chatRepository;
        this.chatToAccountRepository = chatToAccountRepository;
        this.instantNowRepository = instantNowRepository;
        this.accountRepository = accountRepository;
    }

    public Optional<String> getSymmetricKey(Account account, long chatId) {
        Optional<Chat> chat = chatRepository.findById( chatId );
        if(chat.isEmpty())
            return Optional.empty();
        return chatToAccountRepository.findChatToAccountByChatAndAccount(chat.get(), account).map(ChatToAccount::key);
    }

    @Transactional
    public long createNewChat(CreateNewChatRequest request, Account currentAccount) {
        validateFriendshipRequests(request, currentAccount);
        final Chat newChat = chatRepository.save(new Chat(0, request.chatName(), request.description(), Instant.now()));
        List<ChatToAccount> newChatToAccounts = request.accountIdToEncryptedSymKeys()
                .stream()
                .map(entry -> createNewChatToAccountEntry(newChat, entry.accountId(), entry.encryptedSymmetricKey(), currentAccount))
                .toList();
        chatToAccountRepository.saveAll(newChatToAccounts);
        return newChat.id();
    }

    private void validateFriendshipRequests(CreateNewChatRequest request, Account currentAccount) {
        List<Long> accountIds = request.accountIdToEncryptedSymKeys()
                .stream()
                .map(AccountIdToEncryptedSymKey::accountId)
                .toList();

        List<Account> withAccounts = accountRepository.findAllById(accountIds);

        if (accountIds.isEmpty() || withAccounts.size() != accountIds.size() || !withAccounts.stream().allMatch(currentAccount::isFriendsWith)) {
            throw new BadRequestException("You don't have a friendship with all accounts or some of the accounts do not exists.");
        }
    }

    private ChatToAccount createNewChatToAccountEntry(final Chat chat, final long withAccountId, final String encryptedSymmetricKey, final Account currentAccount) {
        Optional<Account> withAccount = accountRepository.findAccountById(withAccountId);
        if (withAccount.isEmpty()){
            throw new InternalServerErrorException("Account with ID " + withAccountId + " does not exist, but was previously validated.");
        }
        return new ChatToAccount(0, withAccount.get(), chat, encryptedSymmetricKey, withAccountId == currentAccount.id(), instantNowRepository.get(), null);
    }

}
