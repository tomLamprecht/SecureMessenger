package de.thws.securemessenger.features.authorization.model;

import de.thws.securemessenger.features.messenging.model.TimeSegment;

import java.time.Duration;

public record MaxTimeDifference(long maximalSeconds) {

    /**
     * if the duration between time1 and time2 exceeds the allowed time, this method returns true, false otherwise
     * @return {@code true} if the duration between time1 and time2 exceeds to the allowed time, {@code false} otherwise
     * @throws IllegalArgumentException if time1 is after time2
     */
    public boolean isMoreThanTimeBetween( TimeSegment timeSegment ) {
        return Duration.between( timeSegment.since(), timeSegment.till() ).getSeconds() > maximalSeconds;
    }
}
