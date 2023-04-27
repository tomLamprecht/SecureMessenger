package de.thws.biedermann.messenger.demo.shared.adapter;

import de.thws.biedermann.messenger.demo.shared.repository.InstantNowRepository;
import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
public class InstantNowImpl implements InstantNowRepository {

    @Override
    public Instant get( ) {
        return Instant.now();
    }
}
