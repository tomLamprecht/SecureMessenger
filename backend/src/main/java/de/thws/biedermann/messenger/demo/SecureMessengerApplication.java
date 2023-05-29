package de.thws.biedermann.messenger.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@SpringBootApplication
public class SecureMessengerApplication implements WebMvcConfigurer {
    public static void main( String[] args ) {
        SpringApplication.run( SecureMessengerApplication.class, args );
    }

}
