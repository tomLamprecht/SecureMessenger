package de.thws.biedermann.messenger.demo.authorization.adapter;

import de.thws.biedermann.messenger.demo.authorization.logic.UserRepository;
import de.thws.biedermann.messenger.demo.authorization.model.User;
import org.springframework.stereotype.Component;

@Component
public class UserRepositoryDB implements UserRepository {
    @Override
    public User getUserByPublicKey( String privateKey ) {
        return new User(1, "Test");
    }
}
