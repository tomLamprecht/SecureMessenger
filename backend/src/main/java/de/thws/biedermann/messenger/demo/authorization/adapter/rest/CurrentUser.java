package de.thws.biedermann.messenger.demo.authorization.adapter.rest;

import de.thws.biedermann.messenger.demo.authorization.model.User;
import org.springframework.context.annotation.Scope;
import org.springframework.context.annotation.ScopedProxyMode;
import org.springframework.stereotype.Component;

@Component
@Scope(value = "request", proxyMode = ScopedProxyMode.TARGET_CLASS)
public class CurrentUser {
    private User user;

    public User getUser() {
        return user;
    }

    public void setUser( User user ) {
        this.user = user;
    }
}