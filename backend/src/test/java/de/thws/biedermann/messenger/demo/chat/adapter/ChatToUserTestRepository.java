package de.thws.biedermann.messenger.demo.chat.adapter;

import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.chat.repository.ChatToUserRepository;
import de.thws.biedermann.time.TimeSegment;

import java.sql.Time;
import java.time.Instant;
import java.util.Collections;
import java.util.List;

public class ChatToUserTestRepository implements ChatToUserRepository {


    @Override
    public List<TimeSegment> getChatAccessTimeSegmentsOfUser( User user, long chatId ) {
        return List.of( new TimeSegment( Instant.MIN, Instant.MAX ) );
    }
}
