package de.thws.securemessenger.model;

import jakarta.persistence.*;

@Entity
public class Friendship {
    @Id
    @GeneratedValue
    private long id;

    @ManyToOne
    @JoinColumn(name = "FromAccountId")
    private Account fromAccount;

    @ManyToOne
    @JoinColumn(name = "ToAccountId")
    private Account toAccount;

    private boolean accepted;

    public Friendship() {
    }

    public Friendship(long id, Account fromAccount, Account toAccount, boolean accepted) {
        this.id = id;
        this.fromAccount = fromAccount;
        this.toAccount = toAccount;
        this.accepted = accepted;
    }

    public long id() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public Account fromAccount() {
        return fromAccount;
    }

    public void setFromAccount(Account fromAccount) {
        this.fromAccount = fromAccount;
    }

    public Account toAccount() {
        return toAccount;
    }

    public void setToAccount(Account toAccount) {
        this.toAccount = toAccount;
    }

    public boolean accepted() {
        return accepted;
    }

    public void setAccepted(boolean accepted) {
        this.accepted = accepted;
    }
}