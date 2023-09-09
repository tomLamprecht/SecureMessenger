package de.thws.securemessenger.features.messenging.logic;

import de.thws.securemessenger.features.messenging.model.AccountIdToEncryptedSymKey;
import de.thws.securemessenger.features.messenging.model.ChatKey;
import de.thws.securemessenger.features.messenging.model.CreateNewChatRequest;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.ApiExceptions.BadRequestException;
import de.thws.securemessenger.model.ApiExceptions.InternalServerErrorException;
import de.thws.securemessenger.model.ApiExceptions.NotFoundException;
import de.thws.securemessenger.model.ApiExceptions.UnauthorizedException;
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
    private final MessageRepository messageRepository;

    public ChatLogic(ChatRepository chatRepository, ChatToAccountRepository chatToAccountRepository, InstantNowRepository instantNowRepository, AccountRepository accountRepository, MessageRepository messageRepository) {
        this.chatRepository = chatRepository;
        this.chatToAccountRepository = chatToAccountRepository;
        this.instantNowRepository = instantNowRepository;
        this.accountRepository = accountRepository;
        this.messageRepository = messageRepository;
    }

    public Optional<ChatKey> getSymmetricKey(Account account, long chatId) {
        Optional<Chat> chat = chatRepository.findById( chatId );
        if(chat.isEmpty())
            return Optional.empty();
        return chatToAccountRepository.findChatToAccountByChatAndAccount(chat.get(), account).map( ChatKey::byChatToAccount);
    }

    @Transactional
    public long createNewChat(CreateNewChatRequest request, Account currentAccount) {
        if (request.chatName().isBlank()) {
            throw new BadRequestException("Please provide a name for the chat. It cannot be left blank.");
        }
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

        if (accountIds.isEmpty() || withAccounts.size() != accountIds.size() || !withAccounts.stream().filter( acc -> acc.id() != currentAccount.id() ).allMatch(currentAccount::isFriendsWith)) {
            throw new BadRequestException("You don't have a friendship with all accounts or some of the accounts do not exists.");
        }
    }

    private ChatToAccount createNewChatToAccountEntry(final Chat chat, final long withAccountId, final String encryptedSymmetricKey, final Account currentAccount) {
        Optional<Account> withAccount = accountRepository.findAccountById(withAccountId);
        if (withAccount.isEmpty()){
            throw new InternalServerErrorException("Account with ID " + withAccountId + " does not exist, but was previously validated.");
        }
        return new ChatToAccount(0, withAccount.get(), currentAccount, chat, encryptedSymmetricKey, withAccountId == currentAccount.id(), instantNowRepository.get(), null);
    }

    public void deleteChat(long chatId, Account account) {
        Optional<Chat> chat = chatRepository.findById(chatId);

        if (chat.isEmpty()) {
            throw new NotFoundException("Chat with id " + chatId + " not found!");
        }

        var chatToAccount = account.chatToAccounts().stream().filter(entry -> entry.chat().id() == chatId && entry.isAdmin()).findFirst();

        if (chatToAccount.isEmpty()) {
            throw new UnauthorizedException("You are not within the chat with the id " + chatId + " or are not an admin!");
        }

        deleteChatAndRegardingEntries(chat.get());
    }

    @Transactional
    public void deleteChatAndRegardingEntries(Chat chat) {
        var messagesToDelete = messageRepository.findAllByChat(chat);
        var chatToAccountsToDelete = chatToAccountRepository.findAllByChat(chat);

        if (chatToAccountsToDelete.size() > 1) {
            throw new BadRequestException("There are still other accounts within this chat. You can only leave this chat.");
        }

        messageRepository.deleteAll(messagesToDelete);
        chatToAccountRepository.deleteAll(chatToAccountsToDelete);
        chatRepository.delete(chat);
    }

    public void deleteChatGroupPic(long chatId) {
        Optional<Chat> chat = chatRepository.findById(chatId);
        if (chat.isEmpty()) {
            throw new NotFoundException("Chat with id " + chatId + " not found!");
        }

        chat.get().setEncodedGroupPic( null );
        chatRepository.save( chat.get() );
    }

    public void addAdminRights(final long chatId, final Account currentAccount, final long accountId, final boolean isAdmin) {
        Optional<ChatToAccount> currentUserToChat = chatToAccountRepository.findChatToAccountByChatIdAndAccount(chatId, currentAccount);

        if (currentUserToChat.isEmpty() || !currentUserToChat.get().isAdmin()) {
            throw new BadRequestException("You have to be within the Chat and be an administrator to perform this action.");
        }

        Optional<ChatToAccount> targetToChat = chatToAccountRepository.findByChatIdAndAccount_Id(chatId, accountId);

        if (targetToChat.isEmpty()) {
            throw new BadRequestException("The account with the id " + accountId + " is not a member of the chat with the id " + chatId);
        }

        targetToChat.get().setAdmin(isAdmin);

        chatToAccountRepository.save(targetToChat.get());
    }

    public void updateChatGroupPic( final long chatId, final Account currentAccount, final String encodedGroupPic )
    {
        Optional<ChatToAccount> currentUserToChat = chatToAccountRepository.findChatToAccountByChatIdAndAccount(chatId, currentAccount);
        if (currentUserToChat.isEmpty()) {
            throw new BadRequestException("You have to be within the Chat to perform this action.");
        }
        currentUserToChat.get().chat().setEncodedGroupPic( encodedGroupPic );
        chatToAccountRepository.save( currentUserToChat.get() );
    }
}
