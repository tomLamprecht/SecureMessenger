package de.thws.securemessenger.features.authorization.application;

import de.thws.securemessenger.features.authorization.logic.AuthenticationService;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.features.authorization.model.AuthorizationData;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.util.ContentCachingRequestWrapper;

import java.util.Optional;

@Component
public class AuthenticationInterceptor implements HandlerInterceptor {

    private final Logger logger = LoggerFactory.getLogger(AuthenticationInterceptor.class);

    @Autowired
    private CurrentAccount currentAccount;
    @Autowired
    private AuthenticationService authenticationService;

    /**
     * Handles the authorization.
     * The timestamp must be the UTC timestamp in ISO-8601 format, and not older than MAX_TIMESTAMP_DIFF (seconds).
     * The signed message must be base64 encoded.
     * The public key must be sent in the "x-public-key" header to identify the user.
     */
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        logger.info("Intercepted " + request.getRequestURI());

        String timestamp = request.getHeader("x-auth-timestamp");
        String signature = request.getHeader("x-auth-signature");
        String publicKey = request.getHeader("x-public-key");

        logger.info("timestamp from client: " + timestamp);
        logger.info("signature from client: " + signature);
        logger.info("public-key from client: " + publicKey);

        if (timestamp == null || timestamp.isEmpty() || publicKey == null || publicKey.isEmpty() || signature == null || signature.isEmpty()) {
            logger.info("request unauthorized because null value or empty header");
            throw new NotAuthorizedException();
        }

        if (!(request instanceof ContentCachingRequestWrapper contentWrapper)) {
            logger.info("request could not be parsed to ContentCachingRequestWrapper. Maybe the filterChain is broken?");
            throw new NotAuthorizedException();
        }

        String content = new String(contentWrapper.getContentAsByteArray(), contentWrapper.getCharacterEncoding());

        AuthorizationData authData = new AuthorizationData(signature, publicKey, timestamp, request.getMethod().toUpperCase(), request.getRequestURI(), content);
        logger.info("trying to authenticate user with following authentication data: " + authData);

        Optional<Account> optionalUser;
        try {
             optionalUser = authenticationService.getAuthorizedAccount(authData);
        } catch (AuthenticationService.VerifySignatureException e) {
            logger.info("signature could not be verified");
            throw new NotAuthorizedException();
        }

        if (optionalUser.isEmpty()) {
            logger.info("no account associated by this public key");
            throw new NotAuthorizedException();
        }

        currentAccount.setUser(optionalUser.get());
        logger.info("Request authorized; Account id: " + currentAccount.getAccount().id());
        return true;
    }

}