package de.thws.biedermann.messenger.demo.authorization.logic;

import javax.crypto.Cipher;
import java.security.GeneralSecurityException;
import java.security.Key;
import java.security.KeyFactory;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

public class MessageSignatureService {

    private final String encryptionAlgorithm;

    private MessageSignatureService( String encryptionAlgorithm ) {
        this.encryptionAlgorithm = encryptionAlgorithm;
    }

    /**
     * Validates if the originMsg was actually signed by the private key corresponding to the public key.
     *
     * @param publicKey the base64 encoded public key corresponding to the private key of the signer.
     * @param originMsg the original message, which was signed.
     * @param signedMsg the base64 encoded resulting message of the signing.
     * @return {@code true} if and only if the originMsg was signed by the private key corresponding to the public key.
     * {@code false} otherwise.
     * @throws GeneralSecurityException if the encryptionAlgorithm does not exist or is symmetric
     */
    public boolean isValid( String publicKey, String originMsg, String signedMsg ) throws GeneralSecurityException {
        Cipher cipher = Cipher.getInstance( encryptionAlgorithm );
        Key key = createRSAKeyFromString( publicKey );
        cipher.init( Cipher.DECRYPT_MODE, key );
        byte[] decodedSignedMsg = Base64.getDecoder( ).decode( signedMsg );
        String decryptedMsg = new String( cipher.doFinal( decodedSignedMsg ) );
        return decryptedMsg.equals( originMsg );
    }

    public static MessageSignatureService withAlgorithm( String encryptionAlgorithm) {
        return new MessageSignatureService( encryptionAlgorithm );
    }

    private Key createRSAKeyFromString( String key ) throws GeneralSecurityException {
        byte[] byteKey = Base64.getDecoder( ).decode( key );
        X509EncodedKeySpec X509key = new X509EncodedKeySpec( byteKey );
        return KeyFactory.getInstance( encryptionAlgorithm ).generatePublic( X509key );
    }
}
