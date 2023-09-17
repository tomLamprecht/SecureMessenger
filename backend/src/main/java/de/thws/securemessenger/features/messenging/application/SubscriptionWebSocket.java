package de.thws.securemessenger.features.messenging.application;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import de.thws.securemessenger.features.authorization.model.MaxTimeDifference;
import de.thws.securemessenger.features.messenging.logic.WebSocketSessionLogic;
import de.thws.securemessenger.features.messenging.model.TimeSegment;
import de.thws.securemessenger.features.messenging.model.WebSocketMessage;
import de.thws.securemessenger.features.messenging.model.WebsocketMessageType;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.Chat;
import de.thws.securemessenger.model.Message;
import de.thws.securemessenger.model.websocketexceptions.InvalidWebsocketDataException;
import de.thws.securemessenger.repositories.AccountRepository;
import de.thws.securemessenger.repositories.ChatRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.time.Instant;
import java.util.*;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Component
public class SubscriptionWebSocket extends TextWebSocketHandler {

    private static final Logger logger = LoggerFactory.getLogger( SubscriptionWebSocket.class );

    private static final String PAYLOAD_INVALID_MESSAGE = "Payload was not a valid session";

    private static final MaxTimeDifference MAX_TIME_DIFFERENCE = new MaxTimeDifference( 60 );

    private final WebSocketSessionLogic logic;
    private final AccountRepository accountRepository;
    private final ChatRepository chatRepository;


    private final Map<WebSocketSession, SessionInfoWrapper> sessionToInfo = new HashMap<>();
    private final Map<Long, List<WebSocketSession>> chatToSessions = new HashMap<>();

    private final SendingMessagesThread sendingMessagesThread;

    private final ObjectMapper objectMapper;


    public SubscriptionWebSocket( WebSocketSessionLogic logic, AccountRepository accountRepository, ChatRepository chatRepository, ObjectMapper objectMapper ) {
        this.logic = logic;
        this.accountRepository = accountRepository;
        this.chatRepository = chatRepository;
        this.objectMapper = objectMapper;
        sendingMessagesThread = new SendingMessagesThread();
        sendingMessagesThread.start();
    }

    public void notifyAllSessions( Message message, long chatId ) {
        List<WebSocketSession> sessions = chatToSessions.get( chatId );
        if ( sessions == null || sessions.isEmpty() )
            return;

        sessions.stream()
                .map( sessionToInfo::get )
                .filter( SessionInfoWrapper::userCanStillReadMessages )
                .forEach( s -> sendingMessagesThread.sendMessage( new WebSocketMessage( message ), s.session ) );
    }

    public void notifyAllSessionsOfUpdatedMessage( Message message, long chatId ) {
        List<WebSocketSession> sessions = chatToSessions.get( chatId );
        if ( sessions == null || sessions.isEmpty() )
            return;

        sessions.stream()
                .map( sessionToInfo::get )
                .forEach( s -> sendingMessagesThread.sendMessage( new WebSocketMessage( message, WebsocketMessageType.UPDATE ), s.session ) );
    }

    public void notifyAllSessionsOfDeletedMessage( long messageId, long chatId ) {
        List<WebSocketSession> sessions = chatToSessions.get( chatId );
        if ( sessions == null || sessions.isEmpty() )
            return;

        sessions.stream()
                .map( sessionToInfo::get )
                .forEach( s -> sendingMessagesThread.sendMessage( WebSocketMessage.createDeleteMessage( messageId ), s.session ) );
    }

    @Override
    public void handleTextMessage( WebSocketSession session, TextMessage message ) {
        logger.info( "Incomming message from Websocket " + message.getPayload() );
        if ( sessionToInfo.containsKey( session ) )
            return; //User already authenticated this session
        try {
            String[] payloadDecrypted = decryptAndSplitPayload( message );
            long chatId = Long.parseLong( payloadDecrypted[0] );
            String accountId = payloadDecrypted[1];
            Instant timestamp = Instant.parse( payloadDecrypted[2] );

            checkIfSessionIsExpired( timestamp );

            SessionInfoWrapper sessionInfoWrapper = new SessionInfoWrapper( session, getAccount( accountId ), chatId );

            populateSessionMaps( session, chatId, sessionInfoWrapper );
            logger.info( "Subscribed accountId " + accountId + " to Chat " + chatId );
        } catch ( InvalidWebsocketDataException e ) {
            logger.info( "Ended Websocket connection because: " + e.getMessage() );
            try {
                session.close();
            } catch ( IOException ex ) { /*can be ignored */}
        }
    }

    private void populateSessionMaps( WebSocketSession session, long chatIdLong, SessionInfoWrapper sessionInfoWrapper ) {
        sessionToInfo.put( session, sessionInfoWrapper );

        insertEmptyListIfChatIsNeverRegisteredBefore( chatIdLong );

        addSessionToListOfSessionsForThisChat( chatIdLong, session );
    }

    private void addSessionToListOfSessionsForThisChat( long chatIdLong, WebSocketSession session ) {
        chatToSessions.merge( chatIdLong, List.of( session ), ( l1, l2 ) -> Stream.of( l1, l2 ).flatMap( List::stream ).collect( Collectors.toList() ) );
    }

    private void insertEmptyListIfChatIsNeverRegisteredBefore( long chatIdLong ) {
        if ( !chatToSessions.containsKey( chatIdLong ) )
            chatToSessions.put( chatIdLong, new ArrayList<>() );
    }

    private Account getAccount( String accountId ) {
        Optional<Account> accountOptional = accountRepository.findAccountById( Long.parseLong( accountId ) );

        if ( accountOptional.isEmpty() )
            throw new InvalidWebsocketDataException( PAYLOAD_INVALID_MESSAGE );
        return accountOptional.get();
    }

    private void checkIfSessionIsExpired( Instant timestamp ) {
        if ( MAX_TIME_DIFFERENCE.isMoreThanTimeBetween( new TimeSegment( timestamp, Instant.now() ) ) ) {
            throw new InvalidWebsocketDataException( "Session is expired please request a new one..." );
        }
    }

    private String[] decryptAndSplitPayload( TextMessage message ) {
        String[] payloadDecrypted;
        try {
            payloadDecrypted = logic.decrypt( message.getPayload() ).split( WebSocketSessionLogic.SESSION_SPLITERATOR );
            if ( payloadDecrypted.length != 3 )
                throw new Exception();
        } catch ( Exception e ) {
            throw new InvalidWebsocketDataException( PAYLOAD_INVALID_MESSAGE );

        }
        return payloadDecrypted;
    }


    @Override
    public void afterConnectionClosed( WebSocketSession session, CloseStatus status ) {
        SessionInfoWrapper sessionInfoWrapper = sessionToInfo.remove( session );
        logger.info( "Session " + session.getId() + " terminated trying to find a subscription and remove it..." );
        if ( sessionInfoWrapper != null ) {
            chatToSessions.get( sessionInfoWrapper.chatId ).remove( session );
            logger.info( "removed subscription for accountId " + sessionInfoWrapper.account.id() + " and chatId " + sessionInfoWrapper.chatId );
        } else {
            logger.info( "No subscription found for session " + session.getId() );
        }
    }

    public class SessionInfoWrapper {
        WebSocketSession session;
        Account account;
        long chatId;

        public SessionInfoWrapper( WebSocketSession session, Account account, long chatId ) {
            this.session = session;
            this.account = account;
            this.chatId = chatId;
        }

        public boolean userCanStillReadMessages() {
            Optional<Chat> chat = chatRepository.findById( chatId ); //necessary to always get the newest data from the database
            return chat.map( c -> c.isAccountActiveMember( account ) ).orElse( false );
        }
    }

    public class SendingMessagesThread extends Thread {

        Logger logger = LoggerFactory.getLogger( SendingMessagesThread.class );

        private record MessageToSession(WebSocketMessage message, WebSocketSession session) {
        }

        private final BlockingQueue<MessageToSession> queue = new LinkedBlockingQueue<>();

        public void sendMessage( WebSocketMessage message, WebSocketSession session ) {
            queue.add( new MessageToSession( message, session ) );
        }

        private String convertToJson( WebSocketMessage message ) {

            try {
                return objectMapper.writeValueAsString( message );
            } catch ( JsonProcessingException e ) {
                throw new RuntimeException( "Failed to convert object to JSON", e );
            }
        }

        @Override
        public void run() {
            while ( true ) {
                MessageToSession messageToSession = null;
                try {
                    messageToSession = queue.take();
                    messageToSession.session.sendMessage( new TextMessage( convertToJson( messageToSession.message ) ) );
                } catch ( InterruptedException e ) {
                    logger.warn( "There was some critical error while the messaging thread tried to read messages from the system..." );
                    throw new RuntimeException( e );
                } catch ( IOException e ) {
                    //There was just some issue at sending data over the socket to one client. Try to close session and then thread can still go on running...
                    try {
                        messageToSession.session.close();
                    } catch ( IOException ex ) { /*couldn't close the session... nothing to do here */}
                }

            }

        }
    }

}
