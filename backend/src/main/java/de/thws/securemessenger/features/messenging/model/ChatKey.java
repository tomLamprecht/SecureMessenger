package de.thws.securemessenger.features.messenging.model;

import de.thws.securemessenger.model.ChatToAccount;

public class ChatKey {
    String value;
    String encryptedByPublicKey;

    public ChatKey( String value, String encryptedByPublicKey ) {
        this.value = value;
        this.encryptedByPublicKey = encryptedByPublicKey;
    }

    public static ChatKey byChatToAccount( ChatToAccount chatToAccount ){
        return new ChatKey( chatToAccount.key(), chatToAccount.encryptedBy().publicKey() );
    }

    public String getValue() {
        return value;
    }

    public void setValue( String value ) {
        this.value = value;
    }

    public String getEncryptedByPublicKey() {
        return encryptedByPublicKey;
    }

    public void setEncryptedByPublicKey( String encryptedByPublicKey ) {
        this.encryptedByPublicKey = encryptedByPublicKey;
    }
}
