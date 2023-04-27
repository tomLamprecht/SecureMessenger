package de.thws.biedermann.messenger.demo.register.repository;

import java.util.concurrent.CompletableFuture;

public interface IRegistrationDbHandler {

    public CompletableFuture<String> loadCaptchaTextById( String id );
    public CompletableFuture<Void> deleteCaptchaById( String id );

}
