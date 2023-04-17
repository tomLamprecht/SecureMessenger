package de.thws.biedermann.messenger.demo.authorization.logic;

import java.time.Duration;
import java.time.Instant;

/**
 * This class can be used to determine if two timestamps
 */
public class MaxTimeDifference {
    private final long maximalSeconds;

    /**
     * creates a MaxTimeDifference which allows a difference of maximalSeconds
     * @param maximalSeconds the allowed time difference in seconds
     */
    public MaxTimeDifference( long maximalSeconds ) {
        this.maximalSeconds = maximalSeconds;
    }

    /**
     * if the duration between time1 and time2 exceeds the allowed time, this method returns true, false otherwise
     * @param time1 the first timestamp
     * @param time2 the second timestamp, usually LocalDateTime.now();
     * @return {@code true} if the duration between time1 and time2 exceeds to the allowed time, {@code false} otherwise
     * @throws IllegalArgumentException if time1 is after time2
     */
    public boolean isMoreThanTimeBetween( Instant time1, Instant time2) {
        if (time1.isAfter( time2 )) {
            throw new IllegalArgumentException( "time1 must be before or equal to time2" );
        }
        return Duration.between( time1, time2 ).getSeconds() > maximalSeconds;
    }
}
