package de.thws.biedermann.messenger.demo.captcha.repository;

import java.awt.image.BufferedImage;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;

public interface ICaptchaDatabaseHandler {

    public void storeCaptcha( String id, BufferedImage image, String text );
    public Optional<BufferedImage> loadCaptchaImageById(String id );
    public Optional<String> loadCaptchaTextById( String id );
    public void deleteCaptchaById( String id );
}
