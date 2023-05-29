package de.thws.biedermann.messenger.demo;

import de.thws.biedermann.messenger.demo.captcha.application.persistence.CaptchaDatabaseHandler;
import de.thws.biedermann.messenger.demo.captcha.repository.ICaptchaDatabaseHandler;
import de.thws.biedermann.messenger.demo.users.adapter.persistence.RegistrationDbHandler;
import de.thws.biedermann.messenger.demo.users.repository.IRegistrationDbHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Profile;

@Profile("prod")
@org.springframework.context.annotation.Configuration
public class Configuration {
    @Bean
    public IRegistrationDbHandler registrationDbHandler() {
        return new RegistrationDbHandler();
    }

    @Bean
    public ICaptchaDatabaseHandler captchaDatabaseHandler( ) {
        return new CaptchaDatabaseHandler( );
    }
}
