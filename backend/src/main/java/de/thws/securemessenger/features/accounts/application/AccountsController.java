package de.thws.securemessenger.features.accounts.application;

import de.thws.securemessenger.features.accounts.logic.PublicAccountInformationHelper;
import de.thws.securemessenger.features.accounts.modules.PublicAccountInformation;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Optional;

@RestController
@RequestMapping("/accounts")
public class AccountsController {

    private final PublicAccountInformationHelper publicAccountInformationHelper;

    public AccountsController(PublicAccountInformationHelper publicAccountInformationHelper) {
        this.publicAccountInformationHelper = publicAccountInformationHelper;
    }

    @GetMapping(value = "/{userId}")
    public ResponseEntity<PublicAccountInformation> getPublicUserInformation(@PathVariable long userId){
        Optional<PublicAccountInformation> publicAccountInformation = publicAccountInformationHelper.getAccountById(userId);
        System.out.println(publicAccountInformation);
        return publicAccountInformation.map(accountInformation -> ResponseEntity
                .ok()
                .body(accountInformation)
        ).orElseGet(() -> ResponseEntity
                .notFound()
                .build());
    }
}
