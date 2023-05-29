//package de.thws.biedermann.messenger.demo.authorization.adapter.persistence;
//
//import de.thws.biedermann.messenger.demo.chat.model.Message;
//import de.thws.biedermann.messenger.demo.chat.repository.MessageRepository;
//import de.thws.biedermann.messenger.demo.shared.model.TimeSegment;
//import org.springframework.context.annotation.Primary;
//import org.springframework.stereotype.Component;
//
//import java.util.List;
//import java.util.Optional;
//
// todo: delete wenn am 30.05 alles funktioniert
//
//@Component
//@Primary
//public class MessageRepositoryDB implements MessageRepository {
//    @Override
//    public Optional<Message> getMessage( long messageId ) {
//        return Optional.empty( );
//    }
//
//    @Override
//    public List<Message> messagesOfChatBetween( long chatId, List<TimeSegment> timeSegments ) {
//        return null;
//    }
//
//    @Override
//    public int deleteMessage( long messageId ) {
//        return 0;
//    }
//
//    @Override
//    public long writeMessage( Message message ) {
//        return 0;
//    }
//}
