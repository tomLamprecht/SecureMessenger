package de.thws.biedermann.messenger.demo.users.logic;

import de.thws.biedermann.messenger.demo.users.model.CaptchaTry;
import de.thws.biedermann.messenger.demo.users.repository.IRegistrationDbHandler;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;


@Service
public class CaptchaValidator {
    private final IRegistrationDbHandler registrationDbHandler;

    @Autowired
    public CaptchaValidator(IRegistrationDbHandler registrationDbHandler) {
        this.registrationDbHandler = registrationDbHandler;
    }

    public Optional<Boolean> isCaptchaValid ( CaptchaTry captchaTry ) {
        Optional<String> expectedCaptchaText = registrationDbHandler.loadCaptchaTextById( captchaTry.id( ) );
        return expectedCaptchaText.map( s -> checkCaptchaAndCleanup( captchaTry.id( ), s, captchaTry.textTry( ) ) );
    }

    private boolean checkCaptchaAndCleanup( String id, String content, String textTry ) {
        if ( content.equals( textTry ) ) {
            registrationDbHandler.deleteCaptchaById( id );
            return true;
        }
        return false;
    }

}
