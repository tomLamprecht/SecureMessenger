package de.thws.securemessenger.features.accounts.application;

import de.thws.securemessenger.features.accounts.logic.PublicAccountInformationHelper;
import de.thws.securemessenger.features.accounts.modules.PublicAccountInformation;
import de.thws.securemessenger.features.authorization.application.CurrentAccount;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/accounts")
public class AccountsController {

    private final PublicAccountInformationHelper publicAccountInformationHelper;
    private final CurrentAccount currentAccount;


    public AccountsController(PublicAccountInformationHelper publicAccountInformationHelper, CurrentAccount currentAccount) {
        this.publicAccountInformationHelper = publicAccountInformationHelper;
        this.currentAccount = currentAccount;
    }

    @GetMapping(value = "/{accountId:[0-9]+}")
    public ResponseEntity<PublicAccountInformation> getPublicUserInformation(@PathVariable long accountId){
        PublicAccountInformation accountInfos = publicAccountInformationHelper.getPublicAccountInformation(accountId);
        return ResponseEntity.ok(accountInfos);
    }

    @GetMapping("/by-username/{username}")
    public ResponseEntity<PublicAccountInformation> getPublicAccountInformationByUsername(@PathVariable String username) {
        Optional<PublicAccountInformation> publicAccountInformation = publicAccountInformationHelper.getAccountByUsername(username);
        return publicAccountInformation.map(ResponseEntity::ok )
                .orElseGet(() -> ResponseEntity
                .notFound()
                .build());
    }

    @GetMapping("/whoami")
    public ResponseEntity<PublicAccountInformation> getWhoAmI(){
        PublicAccountInformation publicAccountInformation = publicAccountInformationHelper.getPublicAccountInformation( currentAccount.getAccount() );
        return ResponseEntity.ok(publicAccountInformation);
    }

    @PutMapping("/update-profil-pic")
    public ResponseEntity<Void> updateProfilPic(@RequestBody String encodedProfilPic) {
        publicAccountInformationHelper.updateProfilPic(currentAccount.getAccount(), extractTextAfterColon( encodedProfilPic ) );
        return ResponseEntity.ok().build();
    }

    public static String extractTextAfterColon(String inputText) {
        String cleanedText = inputText.replaceAll("[{}\"]", "");

        String[] parts = cleanedText.split(":");

        if (parts.length >= 2) {
            return parts[1].trim();
        } else {
            return "";
        }
    }

    @DeleteMapping("/delete-profil-pic")
    public ResponseEntity<Void> deleteProfilPic() {
        publicAccountInformationHelper.deleteProfilPic( currentAccount.getAccount( ) );
        return ResponseEntity.noContent().build();
    }
}
