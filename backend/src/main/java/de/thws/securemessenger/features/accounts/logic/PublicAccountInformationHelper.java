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
        Optional<Account> account = accountRepository.findAccountById(accountId);
        System.out.println(account);
        return account.map(value -> new PublicAccountInformation(value.id(), value.username(), value.publicKey()));
    }

    public Optional<PublicAccountInformation> getAccountByUsername(String username) {
        Optional<Account> account = accountRepository.findAccountByUsername(username);
        return account.map(value -> new PublicAccountInformation(value.id(), value.username(), value.publicKey()));
    }
}
