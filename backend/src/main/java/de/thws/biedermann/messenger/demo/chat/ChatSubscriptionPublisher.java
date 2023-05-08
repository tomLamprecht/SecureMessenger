package de.thws.biedermann.messenger.demo.chat;

import de.thws.biedermann.messenger.demo.chat.logic.ChatSubscriber;
import de.thws.biedermann.messenger.demo.chat.model.Message;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Stream;

public class ChatSubscriptionPublisher {

    private final Map<Long, List<ChatSubscriber>> chatToChatSubscriptionMap = new HashMap<>();


    public void notifyChatSubscriptions( long chatId, Message message ) {
        Optional.ofNullable( chatToChatSubscriptionMap.get( chatId ) )
                .stream()
                .flatMap( List::stream )
                .forEach( sub -> sub.pushMessageToSink( message ) );
    }


    public void subscribe(ChatSubscriber subscriber ){
        chatToChatSubscriptionMap.merge( subscriber.getChatId(), List.of( subscriber ), ( o, n ) -> Stream.of( o, n ).flatMap( List::stream ).toList() );
    }

    public boolean unsubscribe( ChatSubscriber subscriber){
        return chatToChatSubscriptionMap.get( subscriber.getChatId() ).remove( subscriber );
    }



}
