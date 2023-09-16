package de.thws.securemessenger.repositories;

import org.springframework.stereotype.Repository;

import java.awt.image.BufferedImage;
import java.util.Optional;

@Repository
public interface CaptchaRepository {

    void storeCaptcha( String id, BufferedImage image, String text );
    Optional<BufferedImage> loadCaptchaImageById(String id );
    Optional<String> loadCaptchaTextById( String id );
    void deleteCaptchaById( String id );

}
