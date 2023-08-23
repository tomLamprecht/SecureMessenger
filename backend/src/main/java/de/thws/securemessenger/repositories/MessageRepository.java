package de.thws.securemessenger.repositories;


import de.thws.securemessenger.model.Chat;
import de.thws.securemessenger.model.Message;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {

    List<Message> findByChatIdAndTimeStampBeforeOrderByTimeStampDesc( Long chatId, Instant lastMessageTimestamp, Pageable pageable);
    List<Message> findByChatIdOrderByTimeStampDesc(Long chatId, Pageable pageable);
    List<Message> findAllByChat(Chat chat);

    default List<Message> getNMessagesAfterTimestamp( Long chatId, Instant lastMessageTimestamp, int size) {
        if (lastMessageTimestamp == null) {
            return findByChatIdOrderByTimeStampDesc(chatId, PageRequest.of(0, size));
        } else {
            return findByChatIdAndTimeStampBeforeOrderByTimeStampDesc(chatId, lastMessageTimestamp, PageRequest.of(0, size));
        }
    }

}
