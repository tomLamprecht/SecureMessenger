package de.thws.securemessenger.features.authorization.logic;

import de.thws.securemessenger.features.authorization.model.AuthorizationData;
import de.thws.securemessenger.features.authorization.model.MaxTimeDifference;
import de.thws.securemessenger.features.messenging.model.TimeSegment;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.repositories.AccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.security.*;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.X509EncodedKeySpec;
import java.time.Instant;
import java.time.format.DateTimeParseException;
import java.util.Base64;
import java.util.Optional;

@Service
public class AuthenticationService {
    private static final MaxTimeDifference MAX_TIME_DIFFERENCE = new MaxTimeDifference(500000);

    @Autowired
    private AccountRepository accountRepository;
    
    public Optional<Account> getAuthorizedAccount(AuthorizationData authData) throws VerifySignatureException {
        Instant timestamp;
        try {
            timestamp = Instant.parse(authData.timestamp());
        } catch (DateTimeParseException e) {
            return Optional.empty();
        }

        if (MAX_TIME_DIFFERENCE.isMoreThanTimeBetween(new TimeSegment(timestamp, Instant.now()))) {
            return Optional.empty();
        }

        String messageNotSigned = String.format("%s#%s#%s#%s", authData.method(), authData.path(), authData.timestamp(), authData.requestBody());

        try {
            if (!verifySignature(messageNotSigned, authData.signature(), authData.publicKey())) {
                throw new VerifySignatureException();
            }
        } catch (NoSuchAlgorithmException | InvalidKeyException | SignatureException | InvalidKeySpecException e) {
            throw new VerifySignatureException();
        }

        return accountRepository.findAccountByPublicKey(authData.publicKey());
    }

    public static boolean verifySignature(String message, String signature, String publicKeyBase64) throws NoSuchAlgorithmException, InvalidKeyException, SignatureException, InvalidKeySpecException {
        byte[] publicKeyBytes = Base64.getDecoder().decode(publicKeyBase64);
        X509EncodedKeySpec keySpec = new X509EncodedKeySpec(publicKeyBytes);
        KeyFactory keyFactory = KeyFactory.getInstance("RSA");
        PublicKey publicKey = keyFactory.generatePublic(keySpec);
        Signature sig = Signature.getInstance("SHA256withRSA");
        sig.initVerify(publicKey);
        sig.update(message.getBytes());
        byte[] signatureBytes = Base64.getDecoder().decode(signature);
        return sig.verify(signatureBytes);
    }

    public static class VerifySignatureException extends Exception {

    }

}
