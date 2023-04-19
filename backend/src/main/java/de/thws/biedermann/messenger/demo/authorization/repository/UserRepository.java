package de.thws.biedermann.messenger.demo.authorization.repository;

import de.thws.biedermann.messenger.demo.authorization.model.User;

public interface UserRepository {

    User getUserByPublicKey( String privateKey);

}
