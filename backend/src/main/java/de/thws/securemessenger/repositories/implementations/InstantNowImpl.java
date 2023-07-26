package de.thws.securemessenger.repositories.implementations;

import de.thws.securemessenger.repositories.InstantNowRepository;
import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
public class InstantNowImpl implements InstantNowRepository {

    @Override
    public Instant get( ) {
        return Instant.now();
    }
}
