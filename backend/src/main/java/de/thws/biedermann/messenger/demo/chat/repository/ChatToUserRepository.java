package de.thws.biedermann.messenger.demo.chat.repository;

import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.chat.model.ChatToUser;
import de.thws.biedermann.messenger.demo.shared.model.TimeSegment;

import java.util.List;
import java.util.Optional;

public interface ChatToUserRepository {

    List<TimeSegment> getChatAccessTimeSegmentsOfUser( User user, long chatId);

    Optional<ChatToUser> createChatToUser( ChatToUser chatToUser );

    Optional<ChatToUser> readChatToUser(long id);
}
