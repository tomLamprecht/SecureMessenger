package de.thws.securemessenger.repositories.implementations;

import de.thws.securemessenger.data.InMemoryStorage;
import de.thws.securemessenger.model.Captcha;
import de.thws.securemessenger.repositories.ICaptchaDatabaseHandler;
import org.springframework.stereotype.Component;

import java.awt.image.BufferedImage;
import java.util.Optional;

@Component
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
