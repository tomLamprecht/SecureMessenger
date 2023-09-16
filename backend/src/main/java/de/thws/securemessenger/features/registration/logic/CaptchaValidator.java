package de.thws.securemessenger.features.registration.logic;

import de.thws.securemessenger.features.registration.models.CaptchaTry;
import de.thws.securemessenger.repositories.CaptchaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;


@Service
public class CaptchaValidator {
    private final CaptchaRepository captchaRepository;

    @Autowired
    public CaptchaValidator(CaptchaRepository captchaRepository) {
        this.captchaRepository = captchaRepository;
    }

    public Optional<Boolean> isCaptchaValid ( CaptchaTry captchaTry ) {
        Optional<String> expectedCaptchaText = captchaRepository.loadCaptchaTextById( captchaTry.id( ) );
        return expectedCaptchaText.map( s -> checkCaptchaAndCleanup( captchaTry.id( ), s, captchaTry.textTry( ) ) );
    }

    private boolean checkCaptchaAndCleanup( String id, String content, String textTry ) {
        captchaRepository.deleteCaptchaById( id );
        return content.equals(textTry);
    }

}
