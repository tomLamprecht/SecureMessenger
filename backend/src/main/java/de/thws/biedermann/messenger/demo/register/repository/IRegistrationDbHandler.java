package de.thws.biedermann.messenger.demo.register.repository;

import java.util.Optional;
import java.util.concurrent.CompletableFuture;

public interface IRegistrationDbHandler {

    public CompletableFuture<Optional<Long>> createUser( String username, String publicKey );
    public CompletableFuture<String> loadCaptchaTextById( String id );
    public CompletableFuture<Void> deleteCaptchaById( String id );

}
