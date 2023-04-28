package de.thws.biedermann.messenger.demo;

import de.thws.biedermann.messenger.demo.authorization.adapter.rest.AuthenticationInterceptor;
import de.thws.biedermann.messenger.demo.authorization.adapter.persistence.UserRepositoryDB;
import de.thws.biedermann.messenger.demo.authorization.repository.UserRepository;
import de.thws.biedermann.messenger.demo.chat.adapter.ChatSubscriptionPublisher;
import de.thws.biedermann.messenger.demo.shared.adapter.InstantNowImpl;
import de.thws.biedermann.messenger.demo.shared.repository.InstantNowRepository;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@SpringBootApplication
public class SecureMessengerApplication implements WebMvcConfigurer {

    @Bean
    public UserRepository userRepository() {
        return new UserRepositoryDB();
    }

    @Bean
    public InstantNowRepository instantNowRepository() {
        return new InstantNowImpl();
    }

    @Bean
    public AuthenticationInterceptor authorizationInterceptor() {
        return new AuthenticationInterceptor( userRepository(),  instantNowRepository());
    }

    @Bean
    public ChatSubscriptionPublisher chatSubscriptionPublisher() {
        return new ChatSubscriptionPublisher();
    }

    //@Override deactivated;
    public void addInterceptorsDeactivated( InterceptorRegistry registry ) {
        registry.addInterceptor( authorizationInterceptor() )
                .excludePathPatterns(
                        "/error",
                        "/register",
                        "/captcha",
                        "/captcha/**"
                );
    }

    public static void main( String[] args ) {
        SpringApplication.run( SecureMessengerApplication.class, args );
    }

}
