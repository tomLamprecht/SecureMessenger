package de.thws.securemessenger.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import org.hibernate.annotations.GenericGenerator;

import java.time.Instant;
import java.util.List;
import java.util.stream.Stream;

@Entity
public class Chat {
    @Id
    @GeneratedValue(generator = "randomLong")
    @GenericGenerator(name = "randomLong", strategy = "de.thws.securemessenger.util.RandomLongIdentifier")
    private long id;

    @Column(length = 4095)
    private String name;
    @Column(length = 8191)
    private String description;
    private Instant createdAt;

    @Column(columnDefinition = "TEXT")
    private String encodedGroupPic;

    @JsonIgnore
    @OneToMany( mappedBy = "chat", fetch = FetchType.LAZY )
    private List<Message> messages;

    @JsonIgnore
    @OneToMany( mappedBy = "chat", fetch = FetchType.EAGER )
    private List<ChatToAccount> chatToAccounts;

    public Chat() {
    }

    public Chat( long id, String name, String description, Instant createdAt) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.createdAt = createdAt;
    }

    public Chat( long id, String name, String description, Instant createdAt, String encodedGroupPic ) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.createdAt = createdAt;
        this.encodedGroupPic = encodedGroupPic;
    }

    public List<Account> members() {
        return chatToAccounts.stream().map( ChatToAccount::account ).toList();
    }

    public List<Account> activeMembers() {
        return activeMembersStream().toList();
    }

    private Stream<Account> activeMembersStream() {
        return chatToAccounts.stream()
                .filter( a -> a.leftAt() == null || a.leftAt().isAfter( Instant.now() ) )
                .map( ChatToAccount::account );
    }

    public boolean isAccountActiveMember( Account account ) {
        return activeMembersStream().map( Account::publicKey ).anyMatch( p -> p.equals( account.publicKey() ) );
    }

    public long id() {
        return id;
    }

    public void setId( long id ) {
        this.id = id;
    }

    public String name() {
        return name;
    }

    public void setName( String name ) {
        this.name = name;
    }

    public String description() {
        return description;
    }

    public void setDescription( String description ) {
        this.description = description;
    }

    public Instant createdAt() {
        return createdAt;
    }

    public void setCreatedAt( Instant createdAt ) {
        this.createdAt = createdAt;
    }

    public List<Message> messages() {
        return messages;
    }

    public void setMessages( List<Message> messages ) {
        this.messages = messages;
    }

    public List<ChatToAccount> chatToAccounts() {
        return chatToAccounts;
    }

    public void setChatToAccounts( List<ChatToAccount> chatToAccounts ) {
        this.chatToAccounts = chatToAccounts;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public long getId() {
        return id;
    }

    public String encodedGroupPic( )
    {
        return encodedGroupPic;
    }

    public void setEncodedGroupPic( String encodedGroupPic )
    {
        this.encodedGroupPic = encodedGroupPic;
    }
}