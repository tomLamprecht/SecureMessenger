package de.thws.securemessenger.features.registration.logic;

import de.thws.securemessenger.features.registration.models.UserPayload;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.repositories.AccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class RegisterUser {
    final AccountRepository accountRepository;

    @Autowired
    public RegisterUser(AccountRepository userRepository) {
        this.accountRepository = userRepository;
    }

    public long registerUser (final UserPayload userPayload ) {
        Account newUser = new Account(userPayload.userName(), userPayload.publicKey(), LocalDateTime.now());
        newUser = accountRepository.save(newUser);
        return newUser.id();
    }


}
