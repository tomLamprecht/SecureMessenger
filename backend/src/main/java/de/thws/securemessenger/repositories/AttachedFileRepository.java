package de.thws.securemessenger.repositories;

import de.thws.securemessenger.model.AttachedFile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface AttachedFileRepository extends JpaRepository<AttachedFile, UUID> {
}
