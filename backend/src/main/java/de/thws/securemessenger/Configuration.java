package de.thws.securemessenger;

import de.thws.securemessenger.features.authorization.application.AuthenticationInterceptor;
import jakarta.persistence.EntityManagerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Profile;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Profile("default")
@org.springframework.context.annotation.Configuration
@ComponentScan(basePackages = "de.thws.securemessenger")
@EnableTransactionManagement
public class Configuration implements WebMvcConfigurer {

    @Autowired
    private AuthenticationInterceptor authenticationInterceptor;

    @Bean
    public PlatformTransactionManager transactionManager(EntityManagerFactory emf){
        JpaTransactionManager transactionManager = new JpaTransactionManager();
        transactionManager.setEntityManagerFactory(emf);
        return transactionManager;
    }

    @Override
    public void addInterceptors( InterceptorRegistry registry ) {
        registry.addInterceptor( authenticationInterceptor )
                .addPathPatterns(
                        "/accounts/**",
                        "/chats/**",
                        "/friendships/**"
                );
    }

    //Allow CORS because its a public API
    @Override
    public void addCorsMappings( CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedMethods("*")
                .allowedHeaders("*")
                .allowedOrigins("*");
    }
}
