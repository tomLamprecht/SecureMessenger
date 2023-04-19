package de.thws.biedermann.time;

import java.time.Instant;

public record TimeSegment(Instant since, Instant till) {

    public TimeSegment {
        if ( since.isAfter( till ) )
            throw new IllegalArgumentException();
    }

}
