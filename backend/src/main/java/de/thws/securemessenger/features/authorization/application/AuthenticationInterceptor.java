package de.thws.securemessenger.features.authorization.application;

import de.thws.securemessenger.features.authorization.logic.RateLimitLogic;
import de.thws.securemessenger.features.authorization.model.MaxTimeDifference;
import de.thws.securemessenger.features.messenging.model.TimeSegment;
import de.thws.securemessenger.model.Account;
import de.thws.securemessenger.model.ApiExceptions.UnauthorizedException;
import de.thws.securemessenger.repositories.AccountRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.servlet.HandlerInterceptor;

import java.io.IOException;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.security.*;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.X509EncodedKeySpec;
import java.time.Instant;
import java.time.format.DateTimeParseException;
import java.util.Base64;
import java.util.Optional;

@Component
public class AuthenticationInterceptor implements HandlerInterceptor {
    private static final int MAX_TIME_VALID_SEC = 60;
    private static final int TIME_TOLERANCE_SEC = 10; // Tolerance because other OS may be a little ahead

    private static final String TIMESTAMP_HEADER = "x-auth-timestamp";
    private static final String PUBLIC_KEY_HEADER = "x-public-key";
    private static final String SIGNATURE_HEADER = "x-auth-signature";
    private static final String ERROR_MESSAGE = "Your given signature is invalid!";
    private final Logger logger = LoggerFactory.getLogger(AuthenticationInterceptor.class);
    private final CurrentAccount currentAccount;
    private final AccountRepository accountRepository;
    private final RateLimitLogic rateLimitLogic;

    static {
        if (Security.getProvider(BouncyCastleProvider.PROVIDER_NAME) == null) {
            Security.addProvider(new BouncyCastleProvider());
        }
    }

    @Autowired
    public AuthenticationInterceptor(CurrentAccount currentAccount, AccountRepository accountRepository, RateLimitLogic rateLimitLogic) {
        this.currentAccount = currentAccount;
        this.accountRepository = accountRepository;
        this.rateLimitLogic = rateLimitLogic;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        logger.info("Intercepted " + request.getMethod() + " on " + request.getRequestURI());

        if (isOptionsMethod(request)) {
            return true;
        }

        String publicKeyString = request.getHeader(PUBLIC_KEY_HEADER);
        String authTimestamp = request.getHeader(TIMESTAMP_HEADER);
        String authSignature = request.getHeader(SIGNATURE_HEADER);

        if (isMissingRequiredHeaders(publicKeyString, authTimestamp, authSignature)) {
            response.sendError(HttpStatus.UNAUTHORIZED.value(), "Missing required headers");
            return false;
        }

        if (!rateLimitLogic.registerRequestAndCheckUnderLimit(publicKeyString)) {
            response.sendError(HttpStatus.TOO_MANY_REQUESTS.value());
            return false;
        }

        Instant timestamp = parseTimestamp(authTimestamp);
        TimeSegment timeDelta = new TimeSegment(timestamp.minusSeconds( TIME_TOLERANCE_SEC ), Instant.now());
        String payload = buildPayload(request, timestamp);

        if ( new MaxTimeDifference( MAX_TIME_VALID_SEC + TIME_TOLERANCE_SEC ).isMoreThanTimeBetween(timeDelta)){
            logger.info("User with pubKey " + publicKeyString + " was denied because the timestamp is outdated.");
            response.sendError(HttpStatus.UNAUTHORIZED.value(), ERROR_MESSAGE);
            return false;
        }

        if (!isSignatureValid(publicKeyString, payload, authSignature)) {
            logger.info("User with pubKey " + publicKeyString + " was denied because the signature was invalid.");
            response.sendError(HttpStatus.UNAUTHORIZED.value(), ERROR_MESSAGE);
            return false;
        }

        authorizeAccount(publicKeyString);

        return true;
    }

    private boolean isOptionsMethod(HttpServletRequest request) {
        return request.getMethod().toUpperCase().equals(HttpMethod.OPTIONS.name());
    }

    private boolean isMissingRequiredHeaders(String publicKeyString, String authTimestamp, String authSignature) {
        return publicKeyString == null || authTimestamp == null || authSignature == null;
    }

    private Instant parseTimestamp(String authTimestamp) {
        try {
            return Instant.parse(authTimestamp);
        } catch (DateTimeParseException e) {
            logger.info("timestamp could not be parsed: " + authTimestamp);
            throw new UnauthorizedException(ERROR_MESSAGE);
        }
    }

    private String buildPayload(HttpServletRequest request, Instant timestamp) throws UnsupportedEncodingException {
        String method = request.getMethod();
        String uri = request.getRequestURI();
        String body = getBody(request);

        return method + "#" + uri + "#" + timestamp + "#" + body;
    }

    private boolean isSignatureValid(String publicKeyString, String payload, String authSignature) {
        try {
            return verifySignature(publicKeyString, payload, authSignature);
        } catch (Exception e) {
            throw new UnauthorizedException(ERROR_MESSAGE);
        }
    }

    private void authorizeAccount(String publicKeyString) {
        Optional<Account> authorizedAccount = accountRepository.findAccountByPublicKey(publicKeyString);

        if (authorizedAccount.isEmpty()) {
            logger.info("no account associated with this public key");
            throw new UnauthorizedException(ERROR_MESSAGE);
        }

        currentAccount.setAccount(authorizedAccount.get());
        logger.info("Request authorized with the AccountId " + currentAccount.getAccount().id());
    }

    private boolean verifySignature(String publicKeyString, String payload, String authSignature) throws Exception {
        PublicKey publicKey = getPublicKey(publicKeyString);
        Signature publicSignature = getSignatureInstance(publicKey);
        byte[] signatureBytes = Base64.getDecoder().decode(authSignature);

        publicSignature.update(payload.getBytes(StandardCharsets.UTF_8));
        return publicSignature.verify(signatureBytes);
    }

    private static PublicKey getPublicKey(String base64EncodedHex) throws NoSuchAlgorithmException, InvalidKeySpecException {
        byte[] keyBytes = Base64.getDecoder().decode(base64EncodedHex);
        KeyFactory keyFactory = KeyFactory.getInstance("EC");
        X509EncodedKeySpec publicKeySpec = new X509EncodedKeySpec(keyBytes);

        return keyFactory.generatePublic(publicKeySpec);
    }

    private Signature getSignatureInstance(PublicKey publicKey) throws NoSuchAlgorithmException, InvalidKeyException, NoSuchProviderException {
        Signature publicSignature = Signature.getInstance("SHA256withECDSA", BouncyCastleProvider.PROVIDER_NAME);
        publicSignature.initVerify(publicKey);
        return publicSignature;
    }

    private String getBody(HttpServletRequest request) {
        if (!(request instanceof CustomCachingRequestWrapper contentWrapper)) {
            logger.error("request could not be parsed to CustomCachingRequestWrapper. Maybe the filterChain is broken?");
            throw new HttpServerErrorException(HttpStatus.INTERNAL_SERVER_ERROR);
        }
        String bodyAsString;
        try {
            StringWriter content = new StringWriter();
            contentWrapper.getReader().transferTo( content );
            bodyAsString = content.toString();
        } catch ( IOException e ) {
            logger.error( e.getMessage() );
            throw new HttpServerErrorException(HttpStatus.INTERNAL_SERVER_ERROR);
        }
        return bodyAsString == null || bodyAsString.isEmpty() ? "{}" : bodyAsString;
    }
}
