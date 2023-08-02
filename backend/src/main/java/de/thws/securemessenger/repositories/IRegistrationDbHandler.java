package de.thws.securemessenger.repositories;

import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface IRegistrationDbHandler {
    // TODO merge with CaptchaDatabaseHandler?
    Optional<Integer> createUser( String username, String publicKey );
    Optional<String> loadCaptchaTextById( String id );
    void deleteCaptchaById( String id );

}
