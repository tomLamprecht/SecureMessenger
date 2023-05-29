package de.thws.biedermann.messenger.demo.users.repository;

import java.util.Optional;
import java.util.concurrent.CompletableFuture;

public interface IRegistrationDbHandler {

    Optional<Integer> createUser( String username, String publicKey );
    Optional<String> loadCaptchaTextById( String id );
    void deleteCaptchaById( String id );

}
