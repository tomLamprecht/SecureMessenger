package de.thws.biedermann.messenger.demo.chat.logic;

import de.thws.biedermann.messenger.demo.chat.model.Message;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Sinks;

public class ChatSubscriber {

        private final long chatId;
        private final Sinks.Many<Message> sink;
        private boolean active = true;

        private ChatSubscriber( long chatId, Sinks.Many<Message> sink, Flux<Message> flux ) {
            this.chatId = chatId;
            this.sink = sink;
            flux.doFinally( s -> active = false );
        }

        public static ChatSubscriber of( long chatId, Sinks.Many<Message> sink, Flux<Message> flux ) {
            return new ChatSubscriber( chatId, sink, flux );
        }

        public void pushMessageToSink( Message message ) {
            if(active)
                sink.tryEmitNext( message );
        }

        public long getChatId() {
            return chatId;
        }

        public boolean isActive() {
            return active;
        }

        public void setActive( boolean active ) {
            this.active = active;
        }


}
