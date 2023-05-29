package de.thws.biedermann.messenger.demo;

import de.thws.biedermann.messenger.demo.captcha.application.persistence.CaptchaInMemoryHandler;
import de.thws.biedermann.messenger.demo.captcha.repository.ICaptchaDatabaseHandler;
import de.thws.biedermann.messenger.demo.users.adapter.persistence.RegistrationInMemoryHandler;
import de.thws.biedermann.messenger.demo.users.repository.IRegistrationDbHandler;
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
