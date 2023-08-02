package de.thws.securemessenger.repositories.implementations;

import de.thws.securemessenger.data.DatabaseConnectionManager;
import de.thws.securemessenger.repositories.ICaptchaDatabaseHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Optional;

@Component
public class CaptchaDatabaseHandler extends DatabaseConnectionManager implements ICaptchaDatabaseHandler {
    private static final Logger logger = LoggerFactory.getLogger(CaptchaDatabaseHandler.class);

    public void storeCaptcha( final String id, final BufferedImage image, final String text ) {
        String sqlStatement = "INSERT INTO captcha (id, content, text) VALUES (?, ?, ?);";
        executeStatementWithoutReturnValue(sqlStatement, preparedStatement -> {
            preparedStatement.setString(1, id);
            addBufferedImageToPreparedStatement(2, image, preparedStatement);
            preparedStatement.setString(3, text);
        });
    }

    private static void addBufferedImageToPreparedStatement(final int index, final BufferedImage image, final PreparedStatement preparedStatement) throws SQLException {
        try (ByteArrayOutputStream os = new ByteArrayOutputStream()) {
            ImageIO.write(image, "png", os);
            preparedStatement.setBinaryStream(index, new ByteArrayInputStream(os.toByteArray()));
        } catch (IOException e) {
            logger.info("Error while storing captcha!", e);
            throw new RuntimeException(e);
        }
    }

    public Optional<BufferedImage> loadCaptchaImageById(final String id) {
        String sqlStatement = "SELECT content FROM Captcha WHERE id = ?;";
        return executeStatementWithReturnValue(sqlStatement, preparedStatement -> preparedStatement.setString(1, id))
                .asSingle(result -> result.getBytes(1))
                .flatMap(this::readBufferedImageFromBlob);
    }

    private Optional<BufferedImage> readBufferedImageFromBlob(final byte[] blob) {
        if (blob == null) {
            return Optional.empty();
        }
        try (InputStream is = new ByteArrayInputStream(blob)) {
            return Optional.ofNullable(ImageIO.read(is));
        } catch (IOException e) {
            logger.error("Error loading captcha image", e);
            throw new RuntimeException(e);
        }
    }

    public Optional<String> loadCaptchaTextById( final String id ) {
        String sqlStatement = "SELECT Text FROM Captcha WHERE Id = ?;";
        return executeStatementWithReturnValue(sqlStatement, preparedStatement -> preparedStatement.setString(1, id))
                .asSingle(result -> result.getString(0));
    }

    public void deleteCaptchaById( final String id ) {
        String sqlStatement = "DELETE FROM captcha WHERE id = ?;";
        executeStatementWithoutReturnValue(sqlStatement, preparedStatement -> preparedStatement.setString(1, id));
    }
}
