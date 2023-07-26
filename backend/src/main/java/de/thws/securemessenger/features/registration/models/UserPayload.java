package de.thws.securemessenger.features.registration.models;

public record UserPayload( CaptchaTry captchaTry, String publicKey, String userName ) {

}
