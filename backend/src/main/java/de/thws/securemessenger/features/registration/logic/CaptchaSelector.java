package de.thws.securemessenger.features.registration.logic;

import de.thws.securemessenger.repositories.ICaptchaDatabaseHandler;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.Optional;

@Service
public class CaptchaSelector {

    private final ICaptchaDatabaseHandler captchaDatabaseHandler;

    @Autowired
    public CaptchaSelector(ICaptchaDatabaseHandler captchaDatabaseHandler) {
        this.captchaDatabaseHandler = captchaDatabaseHandler;
    }

    public Optional<StreamingResponseBody> loadCaptchaImageById(String id) {
        Optional<BufferedImage> image = captchaDatabaseHandler.loadCaptchaImageById(id);
        return image.map(bufferedImage -> outputStream -> {
            try (outputStream) {
                ImageIO.write(bufferedImage, "png", outputStream);
                outputStream.flush();
            } catch (IOException e) {
                e.printStackTrace();
            }
        });
    }

}
