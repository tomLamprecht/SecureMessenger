package de.thws.biedermann.messenger.demo.users.logic;

import de.thws.biedermann.messenger.demo.users.model.UserPayload;
import de.thws.biedermann.messenger.demo.users.repository.IRegistrationDbHandler;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class RegisterUser {
    final IRegistrationDbHandler registrationDbHandler;

    @Autowired
    public RegisterUser(IRegistrationDbHandler registrationDbHandler) {
        this.registrationDbHandler = registrationDbHandler;
    }


    public Optional<Integer> registerUser ( final UserPayload userPayload ) {
         return registrationDbHandler.createUser( userPayload.userName(), userPayload.publicKey());
    }
}
