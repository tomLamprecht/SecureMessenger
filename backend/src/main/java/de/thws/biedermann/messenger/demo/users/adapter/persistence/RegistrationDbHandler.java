package de.thws.biedermann.messenger.demo.users.adapter.persistence;

import de.thws.biedermann.databasecon.DatabaseConnectionManager;
import de.thws.biedermann.messenger.demo.users.repository.IRegistrationDbHandler;
import java.util.Optional;

public class RegistrationDbHandler extends DatabaseConnectionManager implements IRegistrationDbHandler {
    public Optional<Integer> createUser( final String username, final String publicKey ) {
        String sqlStatement = "INSERT INTO Account (userName, publicKey) VALUES (?, ?) RETURNING id;";
        return insertStatementWithIdReturn(sqlStatement, preparedStatement -> {
            preparedStatement.setString(1, username);
            preparedStatement.setString(2, publicKey);
        });
    }

    public Optional<String> loadCaptchaTextById( final String id ) {
        String sqlStatement = "SELECT Text FROM Captcha WHERE Id = ?;";
        return executeStatementWithReturnValue(sqlStatement, preparedStatement -> preparedStatement.setString(1, id))
                .asSingle(resultSet -> resultSet.getString(1));
    }

    public void deleteCaptchaById( final String id ) {
        String sqlStatement = "DELETE FROM captcha WHERE id = ?;";
        executeStatementWithoutReturnValue(sqlStatement, preparedStatement -> preparedStatement.setString(1, id));
    }

}
