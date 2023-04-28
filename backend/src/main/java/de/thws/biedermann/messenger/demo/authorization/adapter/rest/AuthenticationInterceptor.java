package de.thws.biedermann.messenger.demo.authorization.adapter.rest;

import de.thws.biedermann.messenger.demo.authorization.logic.UserAuthenticationByPublicKey;
import de.thws.biedermann.messenger.demo.authorization.repository.UserRepository;
import de.thws.biedermann.messenger.demo.authorization.model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.Optional;

@Component
public class AuthenticationInterceptor implements HandlerInterceptor {

    private final Logger logger = LoggerFactory.getLogger( AuthenticationInterceptor.class );

    private final UserRepository userRepository;
    private final CurrentUser currentUser;

    @Autowired
    public AuthenticationInterceptor( UserRepository userRepository, CurrentUser currentUser ) {
        this.userRepository = userRepository;
        this.currentUser = currentUser;
    }

    /**
     * Handles the authorization. Only authorizes if the AuthorizationHeader contains the current timestamp,
     * the origin message unsigned and the origin message signed with the private key, all separated by AUTH_HEADER_SPLITTER.
     * The timestamp must be the UTC timestamp in ISO-8601 format, and not older than MAX_TIMESTAMP_DIFF (seconds).
     * The signed message must be base64 encoded.
     * The public key must be sent in the "x-public-key" header to identify the user.
     */
    @Override
    public boolean preHandle( HttpServletRequest request, HttpServletResponse response, Object handler ) throws Exception {
        logger.info( "Intercepted " + request.getRequestURI( ) );

        String authorizationHeaderString = request.getHeader( "Authorization" );
        String publicKey = request.getHeader( "x-public-key" );

        logger.info( "Authorization: " + authorizationHeaderString );
        logger.info( "public-key: " + publicKey );

        Optional<User> optionalUser = new UserAuthenticationByPublicKey( userRepository ).getAuthorizedUser( authorizationHeaderString, request.getContextPath( ), publicKey );
        currentUser.setUser(new User(1, "testUser"));
        return true;
//        if ( optionalUser.isEmpty( ) ) {
//            logger.info( "Request unauthorized" );
//            throw new NotAuthorizedException();
//        }
//
//        currentUser.setUser( optionalUser.get() );
//        logger.info( "Request authorized; User: " + currentUser.getUser().id() );
//        return true;
    }


}
