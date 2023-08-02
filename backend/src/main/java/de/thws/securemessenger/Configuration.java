package de.thws.securemessenger;

import de.thws.securemessenger.features.authorization.application.AuthenticationInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Profile;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Profile("default")
@org.springframework.context.annotation.Configuration
@ComponentScan(basePackages = "de.thws.securemessenger")
public class Configuration implements WebMvcConfigurer {

    @Autowired
    private AuthenticationInterceptor authenticationInterceptor;

    @Override
    public void addInterceptors( InterceptorRegistry registry ) {
        registry.addInterceptor( authenticationInterceptor )
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
