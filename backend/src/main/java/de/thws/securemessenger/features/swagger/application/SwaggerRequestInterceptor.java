package de.thws.securemessenger.features.swagger.application;

import feign.RequestInterceptor;
import feign.RequestTemplate;
import org.springframework.stereotype.Component;

@Component
public class SwaggerRequestInterceptor implements RequestInterceptor {

    private static final String privateKey = "";

    @Override
    public void apply(RequestTemplate requestTemplate) {

        // Retrieve the account from the RequestContextHolder and add the necessary header to the request
        // Account account = (Account) RequestContextHolder.currentRequestAttributes().getAttribute("currentAccount", RequestAttributes.SCOPE_REQUEST);
        // if (account != null) {
        //     String authorizationHeader = yourService.generateAuthorizationHeader(account);
        //     requestTemplate.header("Authorization", authorizationHeader);
        // }
    }

    private void createTestAccountIfNotExists() {

    }
}
