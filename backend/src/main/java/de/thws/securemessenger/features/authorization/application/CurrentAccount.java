package de.thws.securemessenger.features.authorization.application;

import de.thws.securemessenger.model.Account;
import org.springframework.context.annotation.Scope;
import org.springframework.context.annotation.ScopedProxyMode;
import org.springframework.stereotype.Component;

@Component
@Scope(value = "request", proxyMode = ScopedProxyMode.TARGET_CLASS)
public class CurrentAccount {
    private Account account;

    public Account getAccount() {
        return account;
    }

    public void setUser( Account account) {
        this.account = account;
    }
}