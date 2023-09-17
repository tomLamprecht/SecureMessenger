package de.thws.securemessenger.features.accounts.logic;

import de.thws.securemessenger.features.accounts.modules.PublicAccountInformation;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.ApiExceptions.BadRequestException;
import de.thws.securemessenger.model.ApiExceptions.NotFoundException;
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

    public PublicAccountInformation getPublicAccountInformation(Account currentAccount) {
        return new PublicAccountInformation(currentAccount);
    }

    public PublicAccountInformation getPublicAccountInformation(long accountId) {
        Optional<Account> currentAccount = accountRepository.findAccountById(accountId);
        if (currentAccount.isEmpty()) {
            throw new NotFoundException("Account with id " + accountId + " do not exist");
        }
        return new PublicAccountInformation(currentAccount.get());
    }

    public Optional<PublicAccountInformation> getAccountByUsername(String username) {
        Optional<Account> account = accountRepository.findAccountByUsername(username);
        return account.map(value -> new PublicAccountInformation(value.id(), value.username(), value.publicKey(), value.encodedProfilePic()));
    }

    public void updateProfilPic(final Account currentAccount, final String encodedProfilPic){

        Optional<Account> account = accountRepository.findAccountById( currentAccount.id() );


        if(account.isEmpty())
            throw new BadRequestException( "The current Account Id doesn't exist." );
        account.get().setEncodedProfilePic( encodedProfilPic );

        accountRepository.save( account.get() );
    }

    public void deleteProfilPic(Account currentAccount) {
        Optional<Account> accountById = accountRepository.findAccountById( currentAccount.id() );

        if (accountById.isEmpty()) {
            throw new NotFoundException("Account with the Id " + currentAccount.id() + " not found!");
        }
        accountById.get().setEncodedProfilePic( null );
        accountRepository.save( accountById.get() );
    }
}
