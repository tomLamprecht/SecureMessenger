package de.thws.biedermann.messenger.demo.captcha.logic;

import de.thws.biedermann.messenger.demo.captcha.application.persistence.CaptchaDatabaseHandler;
import de.thws.biedermann.messenger.demo.captcha.repository.ICaptchaDatabaseHandler;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.concurrent.ExecutionException;

public class CaptchaSelector {

    public static StreamingResponseBody loadCaptchaImageById(String id) throws ExecutionException, InterruptedException {
        ICaptchaDatabaseHandler captchaDatabaseHandler = new CaptchaDatabaseHandler();

        BufferedImage image = captchaDatabaseHandler.loadCaptchaImageById(id).get();
        return outputStream -> {
            try {
                ImageIO.write(image, "png", outputStream);
            } catch (IOException e) {
                e.printStackTrace();
            }
        };
    }

}
