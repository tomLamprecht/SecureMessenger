package de.thws.biedermann.messenger.demo.captcha;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Profile("prod")
@ComponentScan(basePackages = "de.thws.biedermann.messenger.demo.captcha")
public class CaptchaConfiguration {

}