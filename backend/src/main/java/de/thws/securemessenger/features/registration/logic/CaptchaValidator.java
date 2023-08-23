package de.thws.securemessenger.features.registration.logic;

import de.thws.securemessenger.features.registration.models.CaptchaTry;
import de.thws.securemessenger.repositories.IRegistrationDbHandler;
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
        registrationDbHandler.deleteCaptchaById( id );
        return content.equals(textTry);
    }

}
