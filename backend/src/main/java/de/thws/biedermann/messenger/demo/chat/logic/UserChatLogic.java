package de.thws.biedermann.messenger.demo.chat.logic;

import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.chat.model.Message;
import de.thws.biedermann.messenger.demo.chat.repository.ChatToUserRepository;
import de.thws.biedermann.messenger.demo.chat.repository.MessageRepository;
import de.thws.biedermann.time.TimeSegment;

import java.time.Instant;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

public class UserChatLogic {

    private final ChatToUserRepository chatToUserRepository;
    private final MessageRepository messageRepository;

    public UserChatLogic( ChatToUserRepository chatToUserRepository, MessageRepository messageRepository ) {
        this.chatToUserRepository = chatToUserRepository;
        this.messageRepository = messageRepository;
    }

    /**
     * Returns a list of all messages the user is allowed to read in the chat,
     * or an empty optional if the chat does not exist or the user is not allowed to access the chat.
     * The list will be empty if the user can read the chat, but there are no messages to be read.
     *
     * @param user   the authenticated user
     * @param chatId the chatId of the messages which should be loaded
     * @return the resulting messages or an empty optional
     */
    public Optional<List<Message>> loadMessages( User user, long chatId ) {
        List<TimeSegment> accessTimes = chatToUserRepository.getChatAccessTimeSegmentsOfUser( user, chatId );

        if ( accessTimes.isEmpty() )
            return Optional.empty();

        return Optional.of( messageRepository.messagesOfChatBetween( chatId, accessTimes ) );
    }

    /**
     * deletes the message if possible
     *
     * @param user      the authenticated user
     * @param messageId the message to be deleted
     * @return true, if the operation was successful,
     * false when the user is not allowed to do this operation or the message does not exist
     */
    public boolean deleteMessage( User user, long messageId ) {
        Optional<Message> message = messageRepository.getMessage( messageId );

        if ( message.isEmpty() || message.get().fromUser() != user.id() )
            return false;

        messageRepository.deleteMessage( messageId );
        return true;
    }


    /**
     * Writes message to chat if possible
     *
     * @param user    the authenticated user
     * @param chatId  the chat where the message should be sent to
     * @param message the sending message
     * @return true if the message could be created, false if a problem occurred
     * (e.g. User has no right to send to this chat or chat doesn't exist)
     */
    public boolean writeNewMessageToChat( User user, long chatId, Message message ) {
        Optional<Instant> latestAccessTime = getLatestAccessTimeOfUser( user, chatId );
        if ( latestAccessTime.isEmpty() || latestAccessTime.get().isBefore( Instant.now() ) )
            return false;

        messageRepository.writeMessage( message );
        return true;
    }

    Optional<Instant> getLatestAccessTimeOfUser( User user, long chatId ) {
        return chatToUserRepository.getChatAccessTimeSegmentsOfUser( user, chatId )
                .stream()
                .map( TimeSegment::till )
                .max( Comparator.naturalOrder() );
    }


}
