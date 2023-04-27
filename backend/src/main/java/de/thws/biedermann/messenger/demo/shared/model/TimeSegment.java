package de.thws.biedermann.messenger.demo.shared.model;

import java.time.Instant;

public record TimeSegment(Instant since, Instant till) {

    public TimeSegment {
        if ( since.isAfter( till ) )
            throw new IllegalArgumentException();
    }

}
