package de.thws.biedermann.messenger.demo.captcha.logic;

import de.thws.biedermann.messenger.demo.captcha.database.CaptchaDatabaseHandler;

import java.util.concurrent.ExecutionException;

public class CaptchaValidator {

    public static boolean isCaptchaValid ( String id, String textTry ) throws ExecutionException, InterruptedException {
        // todo: Kein endpunkt dafür: Beim Registrierungs-post schickt man 2 Daten mit:
        //  CaptchaId und CaptchaText und da wird es dann geprüft
        return CaptchaDatabaseHandler.loadCaptchaTextById( id ).thenApply(content -> content.equals(textTry)).get();
    }

}
