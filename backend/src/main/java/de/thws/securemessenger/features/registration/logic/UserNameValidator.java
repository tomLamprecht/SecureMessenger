package de.thws.securemessenger.features.registration.logic;

import org.springframework.stereotype.Service;

@Service
public class UserNameValidator {
    public boolean isValidUserName(String userName) {
        return !userName.isEmpty() && userName.chars().allMatch(Character::isLetterOrDigit);
    }
}
