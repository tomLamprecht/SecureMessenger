package de.thws.biedermann.messenger.demo.authorization.adapter.rest;

import de.thws.biedermann.messenger.demo.authorization.logic.UserAuthenticationByPublicKey;
import de.thws.biedermann.messenger.demo.authorization.model.AuthorizationData;
import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.authorization.repository.UserRepository;
import de.thws.biedermann.messenger.demo.shared.repository.InstantNowRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.Optional;

@Component
public class AuthenticationInterceptor implements HandlerInterceptor {

    private static final String AUTH_HEADER_SPLITTER = "#";

    private final Logger logger = LoggerFactory.getLogger(AuthenticationInterceptor.class);
    private final UserRepository userRepository;
    private final InstantNowRepository instantNowRepository;

    @Autowired
    private CurrentUser currentUser;

    @Autowired
    public AuthenticationInterceptor(UserRepository userRepository, InstantNowRepository instantNowRepository) {
        this.userRepository = userRepository;
        this.instantNowRepository = instantNowRepository;
    }

    public AuthenticationInterceptor(CurrentUser currentUser, UserRepository userRepository, InstantNowRepository instantNowRepository) {
        this.currentUser = currentUser;
        this.userRepository = userRepository;
        this.instantNowRepository = instantNowRepository;
    }

    private static Optional<AuthorizationData> dataOf(String authorizationHeaderString) {

        String[] parts = authorizationHeaderString.split(AUTH_HEADER_SPLITTER);
        if (parts.length != 3) {
            return Optional.empty();
        }

        return Optional.of(new AuthorizationData(parts[0], parts[1], parts[2]));
    }

    /**
     * Handles the authorization. Only authorizes if the AuthorizationHeader contains the current timestamp,
     * the origin message unsigned and the origin message signed with the private key, all separated by AUTH_HEADER_SPLITTER.
     * The timestamp must be the UTC timestamp in ISO-8601 format, and not older than MAX_TIMESTAMP_DIFF (seconds).
     * The signed message must be base64 encoded.
     * The public key must be sent in the "x-public-key" header to identify the user.
     */
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        logger.info("Intercepted " + request.getRequestURI());

        String authorizationHeaderString = request.getHeader("Authorization");
        String publicKey = request.getHeader("x-public-key");

        logger.info("Authorization: " + authorizationHeaderString);
        logger.info("public-key: " + publicKey);

        if (publicKey == null || publicKey.isEmpty() || authorizationHeaderString == null || authorizationHeaderString.isEmpty()) {
            logger.info("Request unauthorized");
            throw new NotAuthorizedException();
        }

        Optional<AuthorizationData> optionalAuthorizationData = dataOf(authorizationHeaderString);
        if (optionalAuthorizationData.isEmpty()) {
            throw new NotAuthorizedException();
        }
        AuthorizationData authorizationData = optionalAuthorizationData.get();

        Optional<User> optionalUser;
        try {
             optionalUser = new UserAuthenticationByPublicKey(userRepository, instantNowRepository).getAuthorizedUser(authorizationData, request.getContextPath(), publicKey);
        } catch (Exception e) {
            throw new NotAuthorizedException();
        }

        if (optionalUser.isEmpty()) {
            logger.info("Request unauthorized");
            throw new NotAuthorizedException();
        }

        currentUser.setUser(optionalUser.get());
        logger.info("Request authorized; User: " + currentUser.getUser().id());
        return true;
    }

}
