//package de.thws.securemessenger.repositories;
//
//import de.thws.securemessenger.model.AccountActionLog;
//import jakarta.transaction.Transactional;
//import org.springframework.data.jpa.repository.JpaRepository;
//import org.springframework.data.jpa.repository.Modifying;
//import org.springframework.data.jpa.repository.Query;
//import org.springframework.data.repository.query.Param;
//import org.springframework.stereotype.Repository;
//
//import java.time.LocalDateTime;
//import java.util.Optional;
//
//@Repository
//public interface AccountActionLogRepository extends JpaRepository<AccountActionLog, Long> {
//    @Modifying
//    @Transactional
//    void deleteByTimestampBefore(LocalDateTime timestamp);
//
//    @Query("SELECT COUNT(*) FROM AccountActionLog log WHERE log.uri = :uri AND log.accountPublicKey = :accountPublicKey AND log.timestamp >= :startTimestamp")
//    int getCountOfRequestsSince(
//            @Param("actionType") String actionType,
//            @Param("uri") String uri,
//            @Param("startTimestamp") LocalDateTime startTimestamp
//    );
//}
