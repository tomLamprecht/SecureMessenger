package de.thws.biedermann.messenger.demo.users.logic;

import de.thws.biedermann.messenger.demo.users.adapter.persistence.RegistrationDbHandler;
import de.thws.biedermann.messenger.demo.users.model.CaptchaTry;
import de.thws.biedermann.messenger.demo.users.repository.IRegistrationDbHandler;

import java.util.concurrent.ExecutionException;

public class CaptchaValidator {

    final IRegistrationDbHandler registrationDbHandler;

    public CaptchaValidator() {
        this.registrationDbHandler = new RegistrationDbHandler();
    }

    public boolean isCaptchaValid ( final CaptchaTry captchaTry ) throws InterruptedException, ExecutionException {
        return this.registrationDbHandler.loadCaptchaTextById( captchaTry.id( ) ).thenApply( content -> {
            try {
                return checkCaptchaAndCleanup( captchaTry.id( ), content, captchaTry.textTry( ) );
            } catch ( ExecutionException | InterruptedException e ) {
                throw new RuntimeException( e );
            }
        } ).get();
    }

    private boolean checkCaptchaAndCleanup( String id, String content, String textTry ) throws ExecutionException, InterruptedException {
        if (content.equals(textTry)) {
            return this.registrationDbHandler.deleteCaptchaById( id ).thenApply( x -> true ).get( );
        }
        return false;
    }

}
