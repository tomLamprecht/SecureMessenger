package de.thws.securemessenger;

import de.thws.securemessenger.features.authorization.application.AuthenticationInterceptor;
import de.thws.securemessenger.repositories.implementations.CaptchaDatabaseHandler;
import de.thws.securemessenger.repositories.ICaptchaDatabaseHandler;
import de.thws.securemessenger.features.messenging.application.ChatSubscriptionPublisher;
import de.thws.securemessenger.repositories.implementations.InstantNowImpl;
import de.thws.securemessenger.repositories.InstantNowRepository;
import de.thws.securemessenger.repositories.implementations.RegistrationDbHandler;
import de.thws.securemessenger.repositories.IRegistrationDbHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Profile;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Profile("default")
@org.springframework.context.annotation.Configuration
public class Configuration implements WebMvcConfigurer {


    @Bean
    public AuthenticationInterceptor authorizationInterceptor() {
        return new AuthenticationInterceptor();
    }


    @Override
    public void addInterceptors( InterceptorRegistry registry ) {
        registry.addInterceptor( authorizationInterceptor() )
                .excludePathPatterns(
                        "/error",
                        "/users/register",
                        "/register",
                        "/register/**",
                        "/captcha",
                        "/captcha/**"
                );
    }


    //Allows CORS - Turn off for production!
    @Override
    public void addCorsMappings( CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedMethods("*")
                .allowedHeaders("*")
                .allowedOrigins("*");
    }
}