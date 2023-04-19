package de.thws.biedermann.messenger.demo.chat.repository;

import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.time.TimeSegment;

import java.util.List;

public interface ChatToUserRepository {

    List<TimeSegment> getChatAccessTimeSegmentsOfUser( User user, long chatId);
}
