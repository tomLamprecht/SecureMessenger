package de.thws.securemessenger.repositories.implementations;

import de.thws.securemessenger.features.registration.models.User;
import de.thws.securemessenger.repositories.IRegistrationDbHandler;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicInteger;

@Component
public class RegistrationInMemoryHandler implements IRegistrationDbHandler {

    public Map<Integer, User> accountStorage = new HashMap<>();
    protected final AtomicInteger accountCounter = new AtomicInteger(1);
    public Map<String, String> captchaStorage = new HashMap<>();

    @Override
    public Optional<Integer> createUser(String username, String publicKey) {
        Integer userId = accountCounter.getAndIncrement();
        User user = new User(userId, username, publicKey, Instant.now());
        accountStorage.put(userId, user);
        return Optional.of(userId);
    }

    @Override
    public Optional<String> loadCaptchaTextById(String id) {
        return Optional.ofNullable(captchaStorage.get(id));
    }

    @Override
    public void deleteCaptchaById(String id) {
        captchaStorage.remove(id);
    }
}
