package de.thws.securemessenger.features.messenging.model;

import java.time.Instant;

public record TimeSegment(Instant since, Instant till) {

    public TimeSegment {
        if ( since == null || till == null )
            throw new IllegalArgumentException( "null is not allowed!" );
        if ( since.isAfter( till ) )
            throw new IllegalArgumentException( "since must be before or equal to till (since=" + since + ") (till=" + till + ")" );
    }

    /**
     * @param instant
     * @return true if the instant is between since and till, or equal to one of them.
     */
    public boolean contains( Instant instant ) {
        if ( instant == null )
            throw new IllegalArgumentException();

        return !( since != null && instant.isBefore( since ) || till != null && ( instant.isAfter( till ) ) );
    }

}
