package de.thws.securemessenger.repositories;

import org.springframework.stereotype.Repository;

import java.time.Instant;

@Repository
public interface InstantNowRepository {
    Instant get();
}
