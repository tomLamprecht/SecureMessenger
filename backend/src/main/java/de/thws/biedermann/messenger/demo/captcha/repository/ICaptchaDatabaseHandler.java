package de.thws.biedermann.messenger.demo.captcha.repository;

import java.awt.image.BufferedImage;
import java.util.concurrent.CompletableFuture;

public interface ICaptchaDatabaseHandler {

    public CompletableFuture<Void> storeCaptcha( String id, BufferedImage image, String text );
    public CompletableFuture<BufferedImage> loadCaptchaImageById( String id );
    public CompletableFuture<String> loadCaptchaTextById( String id );
    public CompletableFuture<Void> deleteCaptchaById( String id );
}
