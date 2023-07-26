package de.thws.securemessenger.features.messenging.logic;

import de.thws.securemessenger.model.Chat;
import de.thws.securemessenger.repositories.ChatRepository;
import de.thws.securemessenger.repositories.MessageRepository;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.ChatToAccount;
import de.thws.securemessenger.model.Message;
import de.thws.securemessenger.repositories.ChatToAccountRepository;
import de.thws.securemessenger.features.messenging.model.TimeSegment;
import de.thws.securemessenger.repositories.InstantNowRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;
import java.util.function.Predicate;

@Component
public class UserChatLogic {

    @Autowired
    private ChatRepository chatRepository;
    @Autowired
    private ChatToAccountRepository chatToAccountRepository;
    @Autowired
    private MessageRepository messageRepository;
    @Autowired
    private InstantNowRepository instantNowRepository;

    /**
     * Returns a list of all messages the user is allowed to read in the chat,
     * or an empty optional if the chat does not exist or the user is not allowed to access the chat.
     * The list will be empty if the user can read the chat, but there are no messages to be read.
     *
     * @param account the authenticated user
     * @param chatId  the chatId of the messages which should be loaded
     * @return the resulting messages or an empty optional
     */
    public Optional<List<Message>> getAllowedMessages(Account account, long chatId) {
        Optional<Chat> chat = chatRepository.findById(chatId);
        if(chat.isEmpty() || notAMember(account, chat.get())) {
            return Optional.empty();
        }

        List<TimeSegment> accountAccessTimes = chat.get()
                .chatToAccounts()
                .stream()
                .filter(chatToAccount -> chatToAccount.account().id() == account.id())
                .map(c -> new TimeSegment(c.joinedAt(), c.leftAt()))
                .toList();

        Predicate<Message> isInAccessTimes = message -> accountAccessTimes.stream().anyMatch(a -> a.contains(message.timeStamp()));

        return Optional.of(chat.get().messages().stream().filter(isInAccessTimes).toList());
    }

    private static boolean notAMember(Account account, Chat chat) {
        return chat.members().stream().noneMatch(member -> member.id() == account.id());
    }

    /**
     * deletes the message if possible
     *
     * @param account   the authenticated user
     * @param messageId the message to be deleted
     * @return true, if the operation was successful,
     * false when the user is not allowed to do this operation or the message does not exist
     */
    public boolean deleteMessageIfAllowed(Account account, long messageId) {
        Optional<Message> message = messageRepository.findById(messageId);

        if (message.isEmpty() || message.get().fromUser().id() != account.id())
            return false;

        messageRepository.deleteById(messageId);
        return true;
    }


    /**
     * Writes message to chat if possible
     *
     * @param account the authenticated user
     * @param chatId  the chat where the message should be sent to
     * @param message the sending message
     * @return true if the message could be created, false if a problem occurred
     * (e.g. User has no right to send to this chat or chat doesn't exist)
     */
    public boolean saveMessageToChatIfAllowed(Account account, long chatId, Message message) {
        if (!accountIsActiveMember(account, chatId))
            return false;

        messageRepository.save(message);
        return true;
    }

    private boolean accountIsActiveMember(Account account, long chatId) {
        // TODO refactor chatToAccount logic
        return false;
    }


    public boolean userCanCreateChatWithOtherUser(Account account, Account invitedAccount) {
        return account.isFriendsWith(invitedAccount);
    }

    public Optional<ChatToAccount> createChatToUserAndReturnResult(ChatToAccount chatToAccount) {
        ChatToAccount insert = new ChatToAccount(
                0,
                chatToAccount.account(),
                chatToAccount.chat(),
                chatToAccount.key(),
                chatToAccount.isAdmin(),
                instantNowRepository.get(),
                null
        );

        return Optional.of(chatToAccountRepository.save(insert));
    }


}
