package de.thws.biedermann.messenger.demo.authorization.logic;

import de.thws.biedermann.messenger.demo.authorization.model.MaxTimeDifference;
import de.thws.biedermann.messenger.demo.authorization.repository.UserRepository;
import de.thws.biedermann.messenger.demo.authorization.model.AuthorizationData;
import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.shared.model.TimeSegment;

import java.time.Instant;
import java.time.format.DateTimeParseException;
import java.util.Optional;

public class UserAuthenticationByPublicKey {
    private final MaxTimeDifference MAX_TIME_DIFFERENCE = new MaxTimeDifference( 5 );
    private static final String AUTH_HEADER_SPLITTER = "#";

    private final UserRepository userRepository;

    public UserAuthenticationByPublicKey( UserRepository userRepository ) {
        this.userRepository = userRepository;
    }

    public Optional<User> getAuthorizedUser( String authorizationHeader, String endpoint, String publicKey ) throws Exception {
        Optional<AuthorizationData> optionalAuthorizationData = dataOf( authorizationHeader );

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

        if ( MAX_TIME_DIFFERENCE.isMoreThanTimeBetween( new TimeSegment( timestamp, Instant.now( ) ) ) ) {
            return Optional.empty( );
        }

        String originMsg = timestamp + endpoint + authorizationData.hashedBody();
        if ( !MessageSignatureService.withAlgorithm( "RSA" ).isValid( publicKey, originMsg, authorizationData.signedMsg() ) ) {
            return Optional.empty( );
        }

        return Optional.ofNullable( userRepository.getUserByPublicKey( publicKey ) );
    }

    private static Optional<AuthorizationData> dataOf( String authorizationString ) {
        if ( authorizationString == null || authorizationString.isEmpty( ) ) {
            return Optional.empty( );
        }

        String[] parts = authorizationString.split( AUTH_HEADER_SPLITTER );
        if ( parts.length != 3 ) {
            return Optional.empty( );
        }

        return Optional.of( new AuthorizationData( parts[0], parts[1], parts[2] ) );
    }


}
