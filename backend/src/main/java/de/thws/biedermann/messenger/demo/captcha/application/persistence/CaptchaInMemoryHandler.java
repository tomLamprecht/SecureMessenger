package de.thws.biedermann.messenger.demo.captcha.application.persistence;

import de.thws.biedermann.inmemory.InMemoryStorage;
import de.thws.biedermann.messenger.demo.captcha.models.Captcha;
import de.thws.biedermann.messenger.demo.captcha.repository.ICaptchaDatabaseHandler;

import java.awt.image.BufferedImage;
import java.util.Optional;

public class CaptchaInMemoryHandler extends InMemoryStorage<String, Captcha> implements ICaptchaDatabaseHandler {
    @Override
    public void storeCaptcha(String id, BufferedImage image, String text) {
        createWithGivenId(id, new Captcha(id, image, text));
    }

    @Override
    public Optional<BufferedImage> loadCaptchaImageById(String id) {
        return Optional.of(loadById(id).bufferedImage());
    }

    @Override
    public Optional<String> loadCaptchaTextById(String id) {
        return Optional.of(loadById(id).content());
    }

    @Override
    public void deleteCaptchaById(String id) {
        remove(id);
    }

    @Override
    protected String generateKey() {
        return String.valueOf(counter.getAndIncrement());
    }
}
