package de.thws.biedermann.messenger.demo.users.adapter.persistence;

import de.thws.biedermann.messenger.demo.users.model.User;
import de.thws.biedermann.messenger.demo.users.repository.IRegistrationDbHandler;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicInteger;

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
