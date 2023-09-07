package de.thws.securemessenger.features.messenging.model;


import java.time.Instant;
import java.util.UUID;

public record FileToFrontend(UUID uuid, String fileName, String encodedFileContent, Instant createdAt) {
}
