package de.thws.securemessenger;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class SecureMessengerApplication {
    public static void main( String[] args ) {
        SpringApplication.run( SecureMessengerApplication.class, args );
    }

}
