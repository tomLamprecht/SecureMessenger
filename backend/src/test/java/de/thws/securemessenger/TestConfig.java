package de.thws.securemessenger;

import de.thws.securemessenger.repositories.implementations.CaptchaInMemoryHandler;
import de.thws.securemessenger.repositories.ICaptchaDatabaseHandler;
import de.thws.securemessenger.repositories.implementations.RegistrationInMemoryHandler;
import de.thws.securemessenger.repositories.IRegistrationDbHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Profile;
import org.springframework.test.context.ContextConfiguration;

@Profile("test")
@ContextConfiguration(classes = { SecureMessengerApplication.class })
@ComponentScan("de.thws.biedermann.messenger.demo")
public class TestConfig {
    @Bean
    public IRegistrationDbHandler registrationDbHandler() {
        return new RegistrationInMemoryHandler();
    }

    @Bean
    public ICaptchaDatabaseHandler captchaDatabaseHandler() {
        return new CaptchaInMemoryHandler();
    }
}
