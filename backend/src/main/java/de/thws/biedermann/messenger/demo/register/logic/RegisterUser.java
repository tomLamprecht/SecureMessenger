package de.thws.biedermann.messenger.demo.register.logic;

import de.thws.biedermann.messenger.demo.register.adapter.persistence.RegistrationDbHandler;
import de.thws.biedermann.messenger.demo.register.model.UserPayload;
import de.thws.biedermann.messenger.demo.register.repository.IRegistrationDbHandler;

import java.util.concurrent.CompletableFuture;

public class RegisterUser {
    final IRegistrationDbHandler registrationDbHandler;

    public RegisterUser() {
        this.registrationDbHandler = new RegistrationDbHandler();
    }

    public CompletableFuture<Integer> registerUser ( final UserPayload userPayload ) {
        return CompletableFuture.completedFuture(1);
    }
}
