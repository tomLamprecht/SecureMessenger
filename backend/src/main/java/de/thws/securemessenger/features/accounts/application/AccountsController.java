package de.thws.securemessenger.features.accounts.application;

import de.thws.securemessenger.features.accounts.logic.PublicAccountInformationHelper;
import de.thws.securemessenger.features.accounts.modules.PublicAccountInformation;
import de.thws.securemessenger.features.authorization.application.CurrentAccount;
import de.thws.securemessenger.model.ApiExceptions.InternalServerErrorException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;
import java.util.logging.Logger;

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
        // Entferne geschweifte Klammern und Anführungsstriche
        String cleanedText = inputText.replaceAll("[{}\"]", "");

        // Teile den Text anhand des Doppelpunkts
        String[] parts = cleanedText.split(":");

        // Überprüfe, ob es mindestens zwei Teile gibt (vor und nach dem Doppelpunkt)
        if (parts.length >= 2) {
            // Extrahiere und trimme den Text nach dem Doppelpunkt
            String extractedText = parts[1].trim();
            return extractedText;
        } else {
            // Falls nicht genügend Teile gefunden wurden, gib einen leeren String zurück
            return "";
        }
    }

    @DeleteMapping("/delete-profil-pic")
    public ResponseEntity<Void> deleteProfilPic() {
        publicAccountInformationHelper.deleteProfilPic( currentAccount.getAccount( ) );
        return ResponseEntity.noContent().build();
    }
}
