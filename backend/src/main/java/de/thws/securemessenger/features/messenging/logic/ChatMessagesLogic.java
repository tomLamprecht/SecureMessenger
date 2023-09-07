package de.thws.securemessenger.features.messenging.logic;

import de.thws.securemessenger.features.messenging.model.TimeSegment;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.ApiExceptions.BadRequestException;
import de.thws.securemessenger.model.Chat;
import de.thws.securemessenger.model.Message;
import de.thws.securemessenger.repositories.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.function.Predicate;

@Component
public class ChatMessagesLogic {

    private final ChatRepository chatRepository;
    private final MessageRepository messageRepository;
    private final AttachedFileRepository attachedFileRepository;

    @Autowired
    public ChatMessagesLogic(ChatRepository chatRepository, MessageRepository messageRepository, AttachedFileRepository attachedFileRepository) {
        this.chatRepository = chatRepository;
        this.messageRepository = messageRepository;
        this.attachedFileRepository = attachedFileRepository;
    }

    /**
     * Returns a list of all messages the user is allowed to read in the chat,
     * or an empty optional if the chat does not exist or the user is not allowed to access the chat.
     * The list will be empty if the user can read the chat, but there are no messages to be read.
     *
     * @param account the authenticated user
     * @param chatId  the chatId of the messages which should be loaded
     * @return the resulting messages or an empty optional
     * @deprecated use {@link #getAllowedMessagesPaginated(Account, long, long, int)} instead. 
     */
    @Deprecated
    public Optional<List<Message>> getAllowedMessages( Account account, long chatId ) {
        Optional<Chat> chat = chatRepository.findById( chatId );
        if ( chat.isEmpty() || notAMember( account, chat.get() ) ) {
            return Optional.empty();
        }

        List<TimeSegment> accountAccessTimes = getAccountAccessTimes( chat.get(), account );

        return Optional.of( chat.get().messages().stream().filter( isInAccessTimePredicate( accountAccessTimes ) ).toList() );
    }

    private Predicate<Message> isInAccessTimePredicate( List<TimeSegment> accountAccessTimes ) {
        return message -> accountAccessTimes.stream().anyMatch( a -> a.contains( message.timeStamp() ) );
    }

    private List<TimeSegment> getAccountAccessTimes( Chat chat, Account account ) {
        return chat
                .chatToAccounts()
                .stream()
                .filter( chatToAccount -> chatToAccount.account().id() == account.id() )
                .map( c -> new TimeSegment( c.joinedAt(), c.leftAt() == null ? Instant.MAX : c.leftAt() ) )
                .toList();
    }

    public Optional<List<Message>> getAllowedMessagesPaginated( Account account, long chatId, long latestMessageId, int size ) {
        Optional<Chat> chat = chatRepository.findById( chatId );
        if ( chat.isEmpty() || notAMember( account, chat.get() ) ) {
            return Optional.empty();
        }

        List<TimeSegment> accountAccessTimes = getAccountAccessTimes( chat.get(), account );

        Optional<Message> latestMessage = latestMessageId == -1 ? Optional.empty() : messageRepository.findById( latestMessageId );

        List<Message> messages = messageRepository.getNMessagesAfterTimestamp( chatId, latestMessage.map( Message::timeStamp ).orElse( null ), size );

        return Optional.of( messages.stream().filter( isInAccessTimePredicate( accountAccessTimes ) ).toList() );
    }

    private static boolean notAMember( Account account, Chat chat ) {
        return chat.members().stream().noneMatch( member -> member.id() == account.id() );
    }

    /**
     * deletes the message if possible
     *
     * @param currentAccount the authenticated user
     * @param messageId      the message to be deleted
     * @return true, if the operation was successful,
     * false when the user is not allowed to do this operation or the message does not exist
     */
    public boolean deleteMessageIfAllowed( Account currentAccount, long messageId, long chatId ) {
        Optional<Message> message = messageRepository.findById( messageId );

        if ( message.isEmpty() || message.get().fromUser().id() != currentAccount.id() || message.get().chat().id() != chatId )
            return false;

        messageRepository.deleteById( messageId );
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
    @Transactional
    public boolean saveMessageToChatIfAllowed( Account account, long chatId, Message message ) {
        if ( !accountIsActiveMember( account, chatId ) )
            return false;

        attachedFileRepository.saveAll(message.getAttachedFiles());
        messageRepository.save( message );
        return true;
    }

    public Message updateMessage( Account account, long chatId, long messageId, String newContent ) {
        Optional<Message> message = messageRepository.findById(messageId).map( m -> {
            m.setValue( newContent );
            m.setLastTimeUpdated( Instant.now( ) );
            return m;
        });

        if ( message.isEmpty() || message.get().fromUser().id() != account.id() || !accountIsActiveMember( account, chatId ) ) {
            throw new BadRequestException("You cannot modify not existing messages or those sent by other members!");
        }

        return messageRepository.save( message.get() );
    }

    private boolean accountIsActiveMember( Account account, long chatId ) {
        Optional<Chat> chat = chatRepository.findById( chatId );
        return chat.map( c -> c.activeMembers().stream()
                        .anyMatch( a -> a.publicKey().equals( account.publicKey() ) ) )
                .orElse( false );
    }
}
