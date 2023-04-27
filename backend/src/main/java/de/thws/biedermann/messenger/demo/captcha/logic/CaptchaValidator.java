package de.thws.biedermann.messenger.demo.captcha.logic;

import de.thws.biedermann.messenger.demo.captcha.application.persistence.CaptchaDatabaseHandler;
import de.thws.biedermann.messenger.demo.captcha.repository.ICaptchaDatabaseHandler;

import java.util.concurrent.ExecutionException;

public class CaptchaValidator {

    public static boolean isCaptchaValid ( String id, String textTry ) throws ExecutionException, InterruptedException {
        ICaptchaDatabaseHandler captchaDatabaseHandler = new CaptchaDatabaseHandler();

        return captchaDatabaseHandler.loadCaptchaTextById( id ).thenApply(content -> {
            try {
                return checkCaptchaAndCleanup(id, content, textTry);
            } catch (ExecutionException | InterruptedException e) {
                throw new RuntimeException(e);
            }
        }).get();
    }

    private static boolean checkCaptchaAndCleanup(String id, String content, String textTry) throws ExecutionException, InterruptedException {
        ICaptchaDatabaseHandler captchaDatabaseHandler = new CaptchaDatabaseHandler();

        if (content.equals(textTry)) {
            return captchaDatabaseHandler.deleteCaptchaById(id).thenApply(x -> true).get();
        }
        return false;
    }

}
