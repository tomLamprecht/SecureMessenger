package de.thws.securemessenger.features.registration.application;

import de.thws.securemessenger.features.registration.logic.CaptchaValidator;
import de.thws.securemessenger.features.registration.logic.RegisterUser;
import de.thws.securemessenger.features.registration.logic.UserNameValidator;
import de.thws.securemessenger.features.registration.models.UserPayload;
import de.thws.securemessenger.repositories.AccountRepository;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.Optional;

@RestController
@RequestMapping( "/users/register" )
public class RegistrationController {

    private final CaptchaValidator captchaValidator;
    private final RegisterUser registerUser;
    private final UserNameValidator userNameValidator;
    private final AccountRepository accountRepository;

    @Autowired
    public RegistrationController( CaptchaValidator captchaValidator, RegisterUser registerUser, UserNameValidator userNameValidator, AccountRepository accountRepository ) {
        this.captchaValidator = captchaValidator;
        this.registerUser = registerUser;
        this.userNameValidator = userNameValidator;
        this.accountRepository = accountRepository;
    }

    @PostMapping( produces = MediaType.TEXT_PLAIN_VALUE )
    public ResponseEntity<String> registerUser( HttpServletRequest request, @RequestBody UserPayload userPayload ) throws URISyntaxException {

        Optional<Boolean> captchaValidationResult = captchaValidator.isCaptchaValid( userPayload.captchaTry() );
        if ( captchaValidationResult.isEmpty() || !captchaValidationResult.get() ) {
            return ResponseEntity.badRequest().body( "Captcha was not correct. Please retry with a new one." );
        }
        if ( !userNameValidator.isValidUserName( userPayload.userName() ) ) {
            return ResponseEntity.badRequest().body( "Invalid userName was given. Only letters and numbers are allowed!" );
        }
        if ( accountRepository.findAccountByUsername( userPayload.userName() ).isPresent() ) {
            return ResponseEntity.status( HttpStatus.CONFLICT ).body( "Username is already taken" );
        }


        long result = registerUser.registerUser( userPayload );

        if ( result == 0 )
            return ResponseEntity.internalServerError().build();


        return ResponseEntity
                .created( new URI( request.getRequestURI() + "/" + result ) )
                .build();
    }

}
