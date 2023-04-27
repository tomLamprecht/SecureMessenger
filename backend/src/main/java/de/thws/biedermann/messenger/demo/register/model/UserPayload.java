package de.thws.biedermann.messenger.demo.register.model;

public record UserPayload( CaptchaTry captchaTry, String publicKey, String userName ) {

}
