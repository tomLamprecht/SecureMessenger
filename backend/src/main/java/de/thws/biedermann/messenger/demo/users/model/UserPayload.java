package de.thws.biedermann.messenger.demo.users.model;

public record UserPayload( CaptchaTry captchaTry, String publicKey, String userName ) {

}