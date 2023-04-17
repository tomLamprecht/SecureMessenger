package de.thws.biedermann.messenger.demo.authorization.application;

import de.thws.biedermann.messenger.demo.authorization.logic.AuthorizationDataService;
import de.thws.biedermann.messenger.demo.authorization.logic.MaxTimeDifference;
import de.thws.biedermann.messenger.demo.authorization.logic.MessageSignatureService;
import de.thws.biedermann.messenger.demo.authorization.logic.UserRepository;
import de.thws.biedermann.messenger.demo.authorization.model.AuthorizationData;
import de.thws.biedermann.messenger.demo.authorization.model.User;

import java.time.Instant;
import java.time.format.DateTimeParseException;
import java.util.Optional;

public class AuthorizeUserByPublicKey {
    private final MaxTimeDifference MAX_TIME_DIFFERENCE = new MaxTimeDifference( 5 );

    private final UserRepository userRepository;

    public AuthorizeUserByPublicKey( UserRepository userRepository ) {
        this.userRepository = userRepository;
    }

    public Optional<User> getAuthorizedUser( String authorizationHeader, String endpoint, String publicKey ) throws Exception {
        Optional<AuthorizationData> optionalAuthorizationData = AuthorizationDataService.dataOf( authorizationHeader );

        if ( optionalAuthorizationData.isEmpty( ) ) {
            return Optional.empty( );
        }

        if ( publicKey == null || publicKey.isEmpty( ) ) {
            return Optional.empty( );
        }

        AuthorizationData authorizationData = optionalAuthorizationData.get( );
        Instant timestamp;
        try {
            timestamp = Instant.parse( authorizationData.timestamp() );
        } catch ( DateTimeParseException e ) {
            return Optional.empty( );
        }

        if ( MAX_TIME_DIFFERENCE.isMoreThanTimeBetween( timestamp, Instant.now( ) ) ) {
            return Optional.empty( );
        }

        String originMsg = timestamp + endpoint + authorizationData.hashedBody();
        if ( !MessageSignatureService.withAlgorithm( "RSA" ).isValid( publicKey, originMsg, authorizationData.signedMsg() ) ) {
            return Optional.empty( );
        }

        return Optional.ofNullable( userRepository.getUserByPublicKey( publicKey ) );
    }


}
