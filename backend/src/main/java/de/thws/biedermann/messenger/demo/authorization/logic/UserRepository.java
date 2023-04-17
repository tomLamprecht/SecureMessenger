package de.thws.biedermann.messenger.demo.authorization.logic;

import de.thws.biedermann.messenger.demo.authorization.model.User;

public interface UserRepository {

    User getUserByPublicKey( String privateKey);

}
