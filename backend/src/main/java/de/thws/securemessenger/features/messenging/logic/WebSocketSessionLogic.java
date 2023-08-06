package de.thws.securemessenger.features.messenging.logic;

import de.thws.securemessenger.features.messenging.model.WebsocketSessionKey;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.util.FileResourceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.io.FileNotFoundException;
import java.security.Key;
import java.time.Instant;
import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.util.Base64;

@Component
public class WebSocketSessionLogic {

    public static final String SESSION_SPLITERATOR = "#";
    private static final String SECURE_KEY_PATH = "secure.key";
    private static final String ALGORITHM = "AES";

    private final String secretKey;

    @Autowired
    public WebSocketSessionLogic( FileResourceService fileResourceService ) throws FileNotFoundException {
        try {
            secretKey = fileResourceService.readResourceFile( SECURE_KEY_PATH );
        } catch ( RuntimeException e ) {
            throw new FileNotFoundException( "There is no key provided under " + SECURE_KEY_PATH );
        }

    }

    public WebsocketSessionKey createSessionKey( long chatId, Account account ) {
        String session = chatId + SESSION_SPLITERATOR + account.id() + SESSION_SPLITERATOR + Instant.now();
        String encryptedSession = encrypt( session );
        return new WebsocketSessionKey(encryptedSession);
    }


    public String encrypt( String data ) {
        try {
            Key key = new SecretKeySpec( Base64.getDecoder().decode( secretKey ), ALGORITHM );
            Cipher cipher = Cipher.getInstance( ALGORITHM );
            cipher.init( Cipher.ENCRYPT_MODE, key );

            byte[] encryptedBytes = cipher.doFinal( data.getBytes() );

            return Base64.getEncoder().encodeToString( encryptedBytes );
        } catch ( Exception e ) {
            throw new RuntimeException( e );
        }
    }


    public String decrypt( String data ) {
        try {
            Key keyObject = new SecretKeySpec( Base64.getDecoder().decode( secretKey ), ALGORITHM );
            Cipher cipher = Cipher.getInstance( ALGORITHM );
            cipher.init( Cipher.DECRYPT_MODE, keyObject );

            byte[] originalBytes = cipher.doFinal( Base64.getDecoder().decode( data ) );

            return new String( originalBytes );
        } catch ( Exception e ) {
            throw new RuntimeException();
        }
    }

}
