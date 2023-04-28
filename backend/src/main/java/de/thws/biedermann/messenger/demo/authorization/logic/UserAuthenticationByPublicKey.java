package de.thws.biedermann.messenger.demo.authorization.logic;

import de.thws.biedermann.messenger.demo.authorization.model.MaxTimeDifference;
import de.thws.biedermann.messenger.demo.authorization.repository.UserRepository;
import de.thws.biedermann.messenger.demo.authorization.model.AuthorizationData;
import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.shared.model.TimeSegment;
import de.thws.biedermann.messenger.demo.shared.repository.InstantNowRepository;

import java.time.Instant;
import java.time.format.DateTimeParseException;
import java.util.Optional;

public class UserAuthenticationByPublicKey {
    private final MaxTimeDifference MAX_TIME_DIFFERENCE = new MaxTimeDifference( 5 );

    private final UserRepository userRepository;
    private final InstantNowRepository instantNowRepository;

    public UserAuthenticationByPublicKey( UserRepository userRepository, InstantNowRepository instantNowRepository ) {
        this.userRepository = userRepository;
        this.instantNowRepository = instantNowRepository;
    }

    public Optional<User> getAuthorizedUser( AuthorizationData authorizationData, String endpoint, String publicKey ) throws Exception {

        Instant timestamp;
        try {
            timestamp = Instant.parse( authorizationData.timestamp() );
        } catch ( DateTimeParseException e ) {
            return Optional.empty( );
        }

        if ( MAX_TIME_DIFFERENCE.isMoreThanTimeBetween( new TimeSegment( timestamp, instantNowRepository.get() ) ) ) {
            return Optional.empty( );
        }

        String originMsg = timestamp + endpoint + authorizationData.hashedBody();
        if ( !MessageSignatureService.withAlgorithm( "RSA" ).isValid( publicKey, originMsg, authorizationData.signedMsg() ) ) {
            return Optional.empty( );
        }

        return Optional.ofNullable( userRepository.getUserByPublicKey( publicKey ) );
    }

}
