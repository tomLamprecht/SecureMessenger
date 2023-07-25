package de.thws.biedermann.messenger.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@SpringBootApplication
public class SecureMessengerApplication {
    public static void main( String[] args ) {
        SpringApplication.run( SecureMessengerApplication.class, args );
    }

}
