package de.thws.biedermann.messenger.demo.register.adapter.persistence;

import de.thws.biedermann.messenger.demo.register.repository.IRegistrationDbHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.concurrent.CompletableFuture;

public class RegistrationDbHandler implements IRegistrationDbHandler {
    private static final String url = "jdbc:postgresql://localhost:5432/mydatabase";
    private static final String user = "postgres";
    private static final String password = "mysecretpassword";

    private static final Logger logger = LoggerFactory.getLogger(RegistrationDbHandler.class);

    public CompletableFuture<String> loadCaptchaTextById( String id ) {
        return CompletableFuture.supplyAsync(() -> {
            try (Connection conn = DriverManager.getConnection(url, user, password)) {
                PreparedStatement statement = conn.prepareStatement("SELECT * FROM Captcha WHERE Id = ?;");
                statement.setString(1, id);
                ResultSet result = statement.executeQuery();
                if (result.next()){
                    String captchaText = result.getString("Text");
                    logger.info(String.format("Captcha text loaded from database for id %s", id));
                    return captchaText;
                }
                return "";
            } catch (SQLException e) {
                logger.info("Error loading captcha text", e);
                throw new RuntimeException(e);
            }
        });
    }

    public CompletableFuture<Void> deleteCaptchaById(String id ) {
        return CompletableFuture.supplyAsync(() -> {
            try (Connection conn = DriverManager.getConnection(url, user, password)) {
                PreparedStatement statement = conn.prepareStatement("DELETE FROM captcha WHERE id = ?");
                statement.setString(1, id);
                statement.execute();
            } catch (SQLException e) {
                logger.info("Error storing captcha", e);
                throw new RuntimeException(e);
            }
            return null;
        });
    }

}
