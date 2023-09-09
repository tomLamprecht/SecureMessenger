package de.thws.securemessenger.features.messenging.logic;

import de.thws.securemessenger.features.messenging.model.AccountResponse;
import de.thws.securemessenger.features.messenging.model.AccountToChat;
import de.thws.securemessenger.features.messenging.model.ChatToAccountResponse;
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

    public List<AccountResponse> getAllAccountsInChat(final long chatId, final Account currentAccount) {
        validateChatAccess(chatId, currentAccount);
        var accountsInChat = accountRepository.findAllByChatId(chatId);
        return accountsInChat.stream().map(AccountResponse::new).toList();
    }

    public List<ChatToAccountResponse> getAllChatToAccountsInChat(final long chatId, final Account currentAccount) {
        validateChatAccess(chatId, currentAccount);
        var accountsInChat = chatToAccountRepository.findAllByChatId(chatId);
        return accountsInChat.stream().map(ChatToAccountResponse::new).toList();
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

        if (request.stream().map(accountToChat -> chatToAccountRepository.findByChatIdAndAccount_Id(chatId, accountToChat.accountId())).anyMatch(Optional::isPresent)) {
            throw new BadRequestException("Some requested accounts are already a member of the chat!");
        }

        List<Long> requestedAccountIds = request.stream().map(AccountToChat::accountId).toList();
        List<Account> accountsToAdd = validateAndGetFriendAccounts(requestedAccountIds, currentAccount);
        Map<Long, String> accountToSymmetricKey = request.stream()
                .collect(Collectors.toMap(AccountToChat::accountId, AccountToChat::encryptedSymmetricKey));

        List<ChatToAccount> newChatToAccounts = accountsToAdd
                .stream()
                .map(account -> new ChatToAccount(0, account, currentAccount, chat, accountToSymmetricKey.get(account.id()), false, instantNowRepository.get(), null))
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

    private void validateChatAccess(final long chatId, final Account currentAccount) {
        Optional<ChatToAccount> currentAccountToChat = chatToAccountRepository.findByChatIdAndAccount_Id(chatId, currentAccount.id());
        if (currentAccountToChat.isEmpty()) {
            throw new UnauthorizedException("You are not authorized to perform this action without being a member of this chat.");
        }
    }

    private void validateChatAccessAndAdminRole(final long chatId, final Account currentAccount) {
        String errorMessage = "You are not authorized to perform this action without the admin role!";
        Optional<Chat> chat = chatRepository.findById( chatId );
        if(chat.isEmpty())
            throw new UnauthorizedException( errorMessage );

        validateChatAccess(chatId, currentAccount);
    }

    public void leaveChat(long chatId, Account currentAccount) {
        Optional<ChatToAccount> chatToAccount = chatToAccountRepository.findChatToAccountByChatIdAndAccount(chatId, currentAccount);

        if (chatToAccount.isEmpty()) {
            throw new UnauthorizedException("Chat does not exists or you are not a member of it!");
        }
        if (!chatToAccount.get().isAdmin()) {
            chatToAccountRepository.delete(chatToAccount.get());
        } else {
            var adminsInChat = chatToAccountRepository.findAllByChat_IdAndIsAdminEquals(chatId, true);
            if (adminsInChat.size() <= 1) {
                throw new BadRequestException("You are the only admin. You have to grant someone else to admin to leave this chat.");
            }
            chatToAccountRepository.delete(chatToAccount.get());
        }
    }
}
