package de.thws.securemessenger.features.registration.application;

import de.thws.securemessenger.features.registration.logic.CaptchaValidator;
import de.thws.securemessenger.features.registration.logic.RegisterUser;
import de.thws.securemessenger.features.registration.models.UserPayload;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.Optional;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/users/register")
public class RegistrationController {

    private final CaptchaValidator captchaValidator;
    private final RegisterUser registerUser;

    @Autowired
    public RegistrationController(CaptchaValidator captchaValidator, RegisterUser registerUser) {
        this.captchaValidator = captchaValidator;
        this.registerUser = registerUser;
    }

    @PostMapping( produces = MediaType.TEXT_PLAIN_VALUE )
    public ResponseEntity<String> registerUser( HttpServletRequest request, @RequestBody UserPayload userPayload ) throws ExecutionException, InterruptedException, URISyntaxException {

        Optional<Boolean> captchaValidationResult = captchaValidator.isCaptchaValid( userPayload.captchaTry( ) );
        if ( captchaValidationResult.isEmpty( ) ) {
            return ResponseEntity.notFound( ).build( );
        }
        if ( !captchaValidationResult.get( ) ) {
            return ResponseEntity.badRequest( ).body( null );
        }

        Optional<Integer> result = registerUser.registerUser( userPayload );

        if ( result.isPresent( ) ) {
            return ResponseEntity
                    .created( new URI( request.getRequestURI( ) + "/" + result.get( ) ) )
                    .contentType( MediaType.TEXT_PLAIN )
                    .body( result.get().toString() );
        }

        return ResponseEntity.internalServerError().body( null );
    }

}
