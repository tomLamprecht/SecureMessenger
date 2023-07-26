package de.thws.securemessenger.features.authorization.logic;

import de.thws.securemessenger.features.authorization.model.AuthorizationData;
import de.thws.securemessenger.features.authorization.model.MaxTimeDifference;
import de.thws.securemessenger.repositories.AccountRepository;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.features.messenging.model.TimeSegment;
import de.thws.securemessenger.repositories.InstantNowRepository;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.Instant;
import java.time.format.DateTimeParseException;
import java.util.Optional;

public class UserAuthenticationByPublicKey {
    private final MaxTimeDifference MAX_TIME_DIFFERENCE = new MaxTimeDifference(5);

    @Autowired
    private InstantNowRepository instantNowRepository;
    @Autowired
    private AccountRepository accountRepository;

    public Optional<Account> getAuthorizedUser(AuthorizationData authorizationData, String endpoint, String publicKey) throws Exception {

        Instant timestamp;
        try {
            timestamp = Instant.parse(authorizationData.timestamp());
        } catch (DateTimeParseException e) {
            return Optional.empty();
        }

        if (MAX_TIME_DIFFERENCE.isMoreThanTimeBetween(new TimeSegment(timestamp, instantNowRepository.get()))) {
            return Optional.empty();
        }

        String originMsg = timestamp + endpoint + authorizationData.hashedBody();
        if (!MessageSignatureService.withAlgorithm("RSA").isValid(publicKey, originMsg, authorizationData.signedMsg())) {
            return Optional.empty();
        }


        return Optional.ofNullable(accountRepository.findAccountByPublicKey(publicKey));
    }

}
