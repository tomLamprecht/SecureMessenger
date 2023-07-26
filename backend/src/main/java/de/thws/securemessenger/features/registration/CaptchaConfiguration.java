package de.thws.securemessenger.features.registration;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Profile("prod")
@ComponentScan(basePackages = "de.thws.biedermann.messenger.demo.registration") // TODO update
public class CaptchaConfiguration {

}