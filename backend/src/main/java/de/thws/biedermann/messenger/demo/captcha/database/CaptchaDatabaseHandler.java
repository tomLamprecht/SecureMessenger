package de.thws.biedermann.messenger.demo.captcha.database;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.*;
import java.sql.*;
import java.util.concurrent.CompletableFuture;

public class CaptchaDatabaseHandler {
    private static final String url = "jdbc:postgresql://localhost:5432/mydatabase";
    private static final String user = "postgres";
    private static final String password = "mysecretpassword";

    private static final Logger logger = LoggerFactory.getLogger(CaptchaDatabaseHandler.class);

    public static CompletableFuture<Void> storeCaptcha(String id, BufferedImage image, String text ){
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        return CompletableFuture.supplyAsync(() -> {
            try (Connection conn = DriverManager.getConnection(url, user, password);
                 ByteArrayOutputStream os = new ByteArrayOutputStream()) {
                ImageIO.write(image, "png", os);
                InputStream is = new ByteArrayInputStream(os.toByteArray());
                PreparedStatement statement = conn.prepareStatement("INSERT INTO captcha (id, content, text) VALUES (?, ?, ?)");
                statement.setString(1, id);
                statement.setBinaryStream(2, is);
                statement.setString(3, text);
                int rowsAffected = statement.executeUpdate();
                // conn.commit();
                logger.info(String.format("%d rows inserted into captcha table for id %s", rowsAffected, id));
            } catch (SQLException | IOException e) {
                logger.info("Error storing captcha", e);
                throw new RuntimeException(e);
            }
            return null;
        });
    }

    public static CompletableFuture<BufferedImage> loadCaptchaImageById(String id) {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        return CompletableFuture.supplyAsync(() -> {
            try (Connection conn = DriverManager.getConnection(url, user, password)) {
                PreparedStatement statement = conn.prepareStatement("SELECT content FROM Captcha WHERE id = ?");
                statement.setString(1, id);
                ResultSet result = statement.executeQuery();
                if (result.next()) {
                    byte[] blob = result.getBytes("content");
                    if (blob != null) {
                        try (InputStream is = new ByteArrayInputStream(blob)) {
                            BufferedImage image = ImageIO.read(is);
                            logger.info(String.format("Captcha image loaded from database for id %s", id));
                            return image;
                        } catch (IOException e) {
                            logger.info("Error loading captcha image", e);
                            throw new RuntimeException(e);
                        }
                    }
                }
                logger.info(String.format("No captcha image found in database for id %s", id));
                return null;
            } catch (SQLException e) {
                logger.info("Error loading captcha image", e);
                throw new RuntimeException(e);
            }
        });
    }

    public static CompletableFuture<String> loadCaptchaTextById( String id ) {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
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

    public static CompletableFuture<Void> deleteCaptchaById( String id ) {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
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
