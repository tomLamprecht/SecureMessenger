package de.thws.securemessenger.features.authorization.logic;

import de.thws.securemessenger.features.authorization.model.MaxTimeDifference;
import de.thws.securemessenger.features.messenging.model.TimeSegment;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.*;

@Service
public class RateLimitLogic {

    @Value("${securemessenger.settings.rate-limit-per-second}")
    private int rateLimit;

    private static final MaxTimeDifference TIME_DIFF_1_SEC = new MaxTimeDifference(1);

    private final Map<String, Deque<Instant>> publicKeyToRequests = new HashMap<>();

    public boolean registerRequestAndCheckUnderLimit(String publicKey) {
        putRequestNow(publicKey);
        return underRateLimit(publicKey);
    }

    private void putRequestNow(String publicKey) {
        Deque<Instant> deque = publicKeyToRequests.get(publicKey);

        if (deque == null) {
            deque = new ArrayDeque<>();
            publicKeyToRequests.put(publicKey, deque);
        }

        deque.addLast(Instant.now());
    }

    private boolean underRateLimit(String publicKey) {
        Deque<Instant> deque = publicKeyToRequests.get(publicKey);
        if (deque.size() >= rateLimit) {
            return TIME_DIFF_1_SEC.isMoreThanTimeBetween(new TimeSegment(deque.pop(), deque.getLast()));
        }
        return true;
    }

}
