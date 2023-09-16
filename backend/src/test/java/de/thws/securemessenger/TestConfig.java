package de.thws.securemessenger;

import de.thws.securemessenger.repositories.implementations.CaptchaInMemoryRepository;
import de.thws.securemessenger.repositories.CaptchaRepository;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Profile;
import org.springframework.test.context.ContextConfiguration;

@Profile("test")
@ContextConfiguration(classes = { SecureMessengerApplication.class })
@ComponentScan("de.thws.biedermann.messenger.demo")
public class TestConfig {
    @Bean
    public CaptchaRepository captchaDatabaseHandler() {
        return new CaptchaInMemoryRepository();
    }
}
