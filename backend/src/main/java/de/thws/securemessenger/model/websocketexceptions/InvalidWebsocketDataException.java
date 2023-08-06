package de.thws.securemessenger.model.websocketexceptions;

public class InvalidWebsocketDataException extends RuntimeException{
    public InvalidWebsocketDataException( String message ) {
        super( message );
    }
}
