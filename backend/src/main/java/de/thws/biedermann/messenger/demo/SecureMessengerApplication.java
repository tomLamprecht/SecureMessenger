package de.thws.biedermann.messenger.demo;

import de.thws.biedermann.messenger.demo.authorization.adapter.AuthorizationInterceptor;
import de.thws.biedermann.messenger.demo.authorization.adapter.CurrentUser;
import de.thws.biedermann.messenger.demo.authorization.adapter.UserRepositoryDB;
import de.thws.biedermann.messenger.demo.authorization.logic.UserRepository;
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
	public AuthorizationInterceptor authorizationInterceptor() {
		return new AuthorizationInterceptor( userRepository(), currentUser() );
	}

	@Override
	public void addInterceptors(InterceptorRegistry registry) {
		registry.addInterceptor( authorizationInterceptor() );
	}

	public static void main(String[] args) {
		SpringApplication.run(SecureMessengerApplication.class, args);
	}

}
