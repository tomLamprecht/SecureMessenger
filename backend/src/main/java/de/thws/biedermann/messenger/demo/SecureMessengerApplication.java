package de.thws.biedermann.messenger.demo;

import de.thws.biedermann.messenger.demo.authorization.adapter.rest.AuthenticationInterceptor;
import de.thws.biedermann.messenger.demo.authorization.adapter.rest.CurrentUser;
import de.thws.biedermann.messenger.demo.authorization.adapter.persistence.UserRepositoryDB;
import de.thws.biedermann.messenger.demo.authorization.repository.UserRepository;
import de.thws.biedermann.messenger.demo.chat.adapter.ChatSubscriptionPublisher;
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
    public CurrentUser currentUser() {
        return new CurrentUser();
    }

    @Bean
    public AuthenticationInterceptor authorizationInterceptor() {
        return new AuthenticationInterceptor( userRepository(), currentUser() );
    }

    @Bean
    public ChatSubscriptionPublisher chatSubscriptionPublisher() {
        return new ChatSubscriptionPublisher();
    }

    @Override
    public void addInterceptors( InterceptorRegistry registry ) {
        registry.addInterceptor( authorizationInterceptor() );
    }

    public static void main( String[] args ) {
        SpringApplication.run( SecureMessengerApplication.class, args );
    }

}
