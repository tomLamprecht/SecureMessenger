package de.thws.biedermann.messenger.demo.captcha.logic;

import de.thws.biedermann.messenger.demo.captcha.database.CaptchaDatabaseHandler;

import java.util.concurrent.ExecutionException;

public class CaptchaValidator {

    public static boolean isCaptchaValid ( String id, String textTry ) throws ExecutionException, InterruptedException {
        return CaptchaDatabaseHandler.loadCaptchaTextById( id ).thenApply(content -> {
            try {
                return checkCaptchaAndCleanup(id, content, textTry);
            } catch (ExecutionException | InterruptedException e) {
                throw new RuntimeException(e);
            }
        }).get();
    }

    private static boolean checkCaptchaAndCleanup(String id, String content, String textTry) throws ExecutionException, InterruptedException {
        if (content.equals(textTry)) {
            return CaptchaDatabaseHandler.deleteCaptchaById(id).thenApply(x -> true).get();
        }
        return false;
    }

}
