package de.thws.biedermann.messenger.demo;

import de.thws.biedermann.messenger.demo.authorization.adapter.persistence.UserRepositoryDB;
import de.thws.biedermann.messenger.demo.authorization.adapter.rest.AuthenticationInterceptor;
import de.thws.biedermann.messenger.demo.authorization.repository.UserRepository;
import de.thws.biedermann.messenger.demo.captcha.application.persistence.CaptchaDatabaseHandler;
import de.thws.biedermann.messenger.demo.captcha.repository.ICaptchaDatabaseHandler;
import de.thws.biedermann.messenger.demo.chat.ChatSubscriptionPublisher;
import de.thws.biedermann.messenger.demo.friendRequest.adapter.persistency.FriendshipRepositoryDB;
import de.thws.biedermann.messenger.demo.friendRequest.repository.FriendshipRepository;
import de.thws.biedermann.messenger.demo.shared.adapter.InstantNowImpl;
import de.thws.biedermann.messenger.demo.shared.repository.InstantNowRepository;
import de.thws.biedermann.messenger.demo.users.adapter.persistence.RegistrationDbHandler;
import de.thws.biedermann.messenger.demo.users.repository.IRegistrationDbHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Profile;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;

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

    @Bean
    public UserRepository userRepository() {
        return new UserRepositoryDB();
    }

    @Bean
    public InstantNowRepository instantNowRepository() {
        return new InstantNowImpl();
    }

    @Bean
    public ChatSubscriptionPublisher chatSubscriptionPublisher() {
        return new ChatSubscriptionPublisher();
    }

    @Bean
    public FriendshipRepository friendshipRepository(){ return new FriendshipRepositoryDB(); }

    @Bean
    public AuthenticationInterceptor authorizationInterceptor() {
        return new AuthenticationInterceptor( userRepository(),  instantNowRepository());
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
}
