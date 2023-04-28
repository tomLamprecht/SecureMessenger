package de.thws.biedermann.messenger.demo.register.logic;

import de.thws.biedermann.messenger.demo.register.adapter.persistence.RegistrationDbHandler;
import de.thws.biedermann.messenger.demo.register.model.UserPayload;
import de.thws.biedermann.messenger.demo.register.repository.IRegistrationDbHandler;

import java.util.Optional;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;

public class RegisterUser {
    final IRegistrationDbHandler registrationDbHandler;

    public RegisterUser() {
        this.registrationDbHandler = new RegistrationDbHandler();
    }

    public Optional<Long> registerUser ( final UserPayload userPayload ) throws ExecutionException, InterruptedException {
         return registrationDbHandler.createUser( userPayload.userName(), userPayload.publicKey() ).get();
    }
}
