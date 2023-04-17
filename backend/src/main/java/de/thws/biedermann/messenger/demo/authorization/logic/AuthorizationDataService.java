package de.thws.biedermann.messenger.demo.authorization.logic;

import de.thws.biedermann.messenger.demo.authorization.model.AuthorizationData;

import java.util.Optional;

public class AuthorizationDataService {
    private static final String AUTH_HEADER_SPLITTER = "#";

    public static Optional<AuthorizationData> dataOf( String authorizationString ) {
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
