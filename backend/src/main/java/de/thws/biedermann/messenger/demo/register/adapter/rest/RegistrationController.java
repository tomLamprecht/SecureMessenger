package de.thws.biedermann.messenger.demo.register.adapter.rest;

import de.thws.biedermann.messenger.demo.register.logic.CaptchaValidator;
import de.thws.biedermann.messenger.demo.register.logic.RegisterUser;
import de.thws.biedermann.messenger.demo.register.model.UserPayload;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/register")
public class RegistrationController {

    @PostMapping
    public ResponseEntity<Integer> registerUser( HttpServletRequest request, @RequestBody UserPayload userPayload ) throws ExecutionException, InterruptedException, URISyntaxException {
        final CaptchaValidator captchaValidator = new CaptchaValidator();

        if ( !captchaValidator.isCaptchaValid( userPayload.captchaTry( ) ) ) {
            return ResponseEntity.badRequest().body( null );
        }
        final RegisterUser registerUser = new RegisterUser( );
        return ResponseEntity
                .created( new URI( request.getRequestURI( ) ) )
                .body( registerUser.registerUser( userPayload ).get() );
    }

}
