package de.thws.biedermann.messenger.demo.authorization.model;

import de.thws.biedermann.messenger.demo.shared.model.TimeSegment;

import java.time.Duration;

/**
 * This class can be used to determine if two timestamps habe a longer
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
     * @return {@code true} if the duration between time1 and time2 exceeds to the allowed time, {@code false} otherwise
     * @throws IllegalArgumentException if time1 is after time2
     */
    public boolean isMoreThanTimeBetween( TimeSegment timeSegment ) {
        return Duration.between( timeSegment.since(), timeSegment.till() ).getSeconds() > maximalSeconds;
    }
}
