package de.thws.securemessenger.features.accounts.logic;

import de.thws.securemessenger.features.accounts.modules.PublicAccountInformation;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.repositories.AccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class PublicAccountInformationHelper {

    @Autowired
    private final AccountRepository accountRepository;

    public PublicAccountInformationHelper(AccountRepository accountRepository) {
        this.accountRepository = accountRepository;
    }

    public Optional<PublicAccountInformation> getAccountById(long accountId) {
        Account account = accountRepository.findAccountById(accountId);
        if (account == null) {
            return Optional.empty();
        }
        return Optional.of(new PublicAccountInformation(account.id(), account.username(), account.publicKey()));
    }
}
