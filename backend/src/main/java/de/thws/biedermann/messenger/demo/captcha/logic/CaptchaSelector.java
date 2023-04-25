package de.thws.biedermann.messenger.demo.captcha.logic;

import de.thws.biedermann.messenger.demo.captcha.database.CaptchaDatabaseHandler;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.concurrent.ExecutionException;

public class CaptchaSelector {

    public static StreamingResponseBody loadCaptchaImageById(String id) throws ExecutionException, InterruptedException {
        BufferedImage image = CaptchaDatabaseHandler.loadCaptchaImageById(id).get();
        return outputStream -> {
            try {
                ImageIO.write(image, "png", outputStream);
            } catch (IOException e) {
                e.printStackTrace();
            }
        };
    }

}
