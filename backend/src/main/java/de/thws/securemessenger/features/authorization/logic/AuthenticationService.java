package de.thws.securemessenger.features.authorization.logic;

import de.thws.securemessenger.features.authorization.model.AuthorizationData;
import de.thws.securemessenger.features.authorization.model.MaxTimeDifference;
import de.thws.securemessenger.repositories.AccountRepository;
import de.thws.securemessenger.features.messenging.model.TimeSegment;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.security.*;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.X509EncodedKeySpec;
import java.time.Instant;
import java.util.Base64;

@Service
public class AuthenticationService {
    private static final MaxTimeDifference MAX_TIME_DIFFERENCE = new MaxTimeDifference(500000000);

    @Autowired
    private AccountRepository accountRepository;
    
    public boolean isAuthenticated(AuthorizationData authData) throws VerifySignatureException {
        if (MAX_TIME_DIFFERENCE.isMoreThanTimeBetween(new TimeSegment(authData.timestamp(), Instant.now()))) {
            return false;
        }

        String messageNotSigned = String.format("%s#%s#%s#%s", authData.method(), authData.path(), authData.timestamp(), authData.requestBody().isEmpty() ? "{}" : authData.requestBody());

        try {
            if (!verifySignature(messageNotSigned, authData.signature(), authData.publicKey())) {
                throw new VerifySignatureException("no valid signature");
            }
        } catch (NoSuchAlgorithmException | InvalidKeyException | SignatureException | InvalidKeySpecException e) {
            throw new VerifySignatureException(e);
        }

        return true;
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
        public VerifySignatureException(Exception e) {
            super(e);
        }

        public VerifySignatureException(String s) {
            super(s);
        }
    }

    public static void main(String[] args) throws NoSuchAlgorithmException, SignatureException, InvalidKeySpecException, InvalidKeyException {
        verifySignature("GET#/chats#2023-08-01T22:10:42.631Z#", "dBwW0A/frcfNySCRAhxI+vRf1lD1FiHCdkUgsqaSUYJLOMVuW4hEMb7PjW1NJ1gwiL0nTPjTsqEPd/eeI9F/WvLuXieY+5iqjykX+y7Q1yHn1db1TMPskcK2hXRrS6z3Rnvo6pG7kzqCJDfQAPfxFTFaKBk3OFtcck+P+fVd3QVICAHi4KBH/MtrSu6NiJPLcCEb7kjPaV9CDFIzoKE3TGYJUXTeCNrU3x3QoRf8Ql2rMheWWyjuw233nG0cpsZR+hUCwUdFmPMqYgweRUWF0nHWM23fKUGBbsuB9Gduso4tyTzy5Pra6+1PW7vN4ntpi0b0cshOrCt4zlHJ8q77YQ==", "MIIBCgKCAQEAtPTb1miQwzGtvBq5qZhUpjSrnLiDXbYoqwb0vTxzIxTPH1rrrwm37od08u365o+Qi/xDY8CsamRe9YEz5ptqbB4fkyvWZcA200fd5+3xaecVUih91ROJM2EQSN+LnzNOP+/4x4ywUms10t9rkpQIDij8fJvIwfxhq8kdeWz7b+qLlXOAx9cpCjAVQes81gFZq/FXU1K+7+jEWvUMTYMoLe0yL8dti6K/fbYkpI6dGpjL/AfhhNXWGr6zBF8mnPYrRFHe7FcSVGWNMUAHtlyGccBqqE+k0uVEWFvBxWr51zSLcM9xzz/WC8CFZWOg5640lmvioElw/zgo9l+tZlA/nQIDAQAB");
    }

}
