package de.thws.securemessenger.features.messenging.logic;

import de.thws.securemessenger.features.messenging.model.AccountToChat;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.ApiExceptions.BadRequestException;
import de.thws.securemessenger.model.ApiExceptions.NotFoundException;
import de.thws.securemessenger.model.ApiExceptions.UnauthorizedException;
import de.thws.securemessenger.model.Chat;
import de.thws.securemessenger.model.ChatToAccount;
import de.thws.securemessenger.repositories.*;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Component
public class ChatMemberLogic {

    private final ChatRepository chatRepository;
    private final ChatToAccountRepository chatToAccountRepository;
    private final InstantNowRepository instantNowRepository;
    private final AccountRepository accountRepository;

    public ChatMemberLogic(ChatRepository chatRepository, ChatToAccountRepository chatToAccountRepository, InstantNowRepository instantNowRepository, AccountRepository accountRepository) {
        this.chatRepository = chatRepository;
        this.chatToAccountRepository = chatToAccountRepository;
        this.instantNowRepository = instantNowRepository;
        this.accountRepository = accountRepository;
    }

    public void deleteAccountFromChat(final long chatId, final long accountId, final Account currentAccount) {
        final String errorMessage = "Either the specified Chat or Account doesn't exist, or the Account is not part of the specified Chat.";
        chatRepository.findById(chatId).orElseThrow(() -> new NotFoundException(errorMessage));
        validateChatAccessAndAdminRole(chatId, currentAccount);
        Account accountToRemove = accountRepository.findAccountById(accountId).orElseThrow(() -> new NotFoundException(errorMessage));

        Chat chat = chatRepository.findById( chatId ).orElseThrow(() -> new NotFoundException( errorMessage ));
        ChatToAccount accountToRemoveToChat = chatToAccountRepository.findChatToAccountByChatAndAccount(chat, accountToRemove).orElseThrow(() -> new NotFoundException(errorMessage));
        chatToAccountRepository.delete(accountToRemoveToChat);
    }

    public void addAccountsToChat(final long chatId, final List<AccountToChat> request, final Account currentAccount) {
        Chat chat = validateAndGetChat(chatId);
        validateChatAccessAndAdminRole(chatId, currentAccount);

        List<Long> requestedAccountIds = request.stream().map(AccountToChat::accountId).toList();
        List<Account> accountsToAdd = validateAndGetFriendAccounts(requestedAccountIds, currentAccount);
        Map<Long, String> accountToSymmetricKey = request.stream()
                .collect(Collectors.toMap(AccountToChat::accountId, AccountToChat::encryptedSymmetricKey));

        List<ChatToAccount> newChatToAccounts = accountsToAdd
                .stream()
                .map(account -> new ChatToAccount(0, account, chat, accountToSymmetricKey.get(account.id()), false, instantNowRepository.get(), null))
                .toList();
        chatToAccountRepository.saveAll(newChatToAccounts);
    }

    private Chat validateAndGetChat(final long chatId) {
        return chatRepository.findById(chatId)
                .orElseThrow(() -> new BadRequestException("Chat with id " + chatId + " does not exists."));
    }

    private List<Account> validateAndGetFriendAccounts(final List<Long> accountIds, final Account currentAccount) {
        List<Account> accountsToAdd = accountRepository.findAccountsById(accountIds)
                .stream()
                .filter(currentAccount::isFriendsWith)
                .toList();

        if (accountsToAdd.size() != accountIds.size()) {
            throw new UnauthorizedException("Some Accounts do not exists or are not a friend of you.");
        }
        return accountsToAdd;
    }

    private void validateChatAccessAndAdminRole(final long chatId, final Account currentAccount) {
        String errorMessage = "You are not authorized to perform this action without the admin role!";
        Optional<Chat> chat = chatRepository.findById( chatId );
        if(chat.isEmpty())
            throw new UnauthorizedException( errorMessage );


        Optional<ChatToAccount> currentAccountToChat = chatToAccountRepository.findChatToAccountByChatAndAccount(chat.get(), currentAccount);
        if (currentAccountToChat.isEmpty() || !currentAccountToChat.get().isAdmin()) {
            throw new UnauthorizedException(errorMessage);
        }
    }
}
