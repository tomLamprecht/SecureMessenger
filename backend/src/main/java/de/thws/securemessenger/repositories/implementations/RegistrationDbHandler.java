package de.thws.securemessenger.repositories.implementations;

import de.thws.securemessenger.data.DatabaseConnectionManager;
import de.thws.securemessenger.repositories.IRegistrationDbHandler;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
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
