package de.thws.securemessenger.model;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.GenericGenerator;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Entity
public class Account {
    @Id
    @GeneratedValue( generator = "randomLong" )
    @GenericGenerator( name = "randomLong", strategy = "de.thws.securemessenger.util.RandomLongIdentifier" )
    private Long id;

    @Column( unique = true, nullable = false )
    private String username;
    @Column( length = 1000, unique = true, nullable = false )
    private String publicKey;

    @CreationTimestamp
    private LocalDateTime joinedAt;

    @OneToMany( mappedBy = "account", fetch = FetchType.EAGER )
    private List<ChatToAccount> chatToAccounts;

    @OneToMany( mappedBy = "toAccount", fetch = FetchType.EAGER )
    private List<Friendship> incomingFriendships;

    @OneToMany( mappedBy = "fromAccount", fetch = FetchType.EAGER )
    private List<Friendship> outgoingFriendships;

    @Column( columnDefinition = "TEXT" )
    private String encodedProfilePic;

    public Account() {
    }

    public Account( long id, String username, String publicKey, LocalDateTime joinedAt ) {
        this.id = id;
        this.username = username;
        this.publicKey = publicKey;
        this.joinedAt = joinedAt;
    }

    public Account( long id, String username, String publicKey, LocalDateTime joinedAt, String encodedProfilePic ) {
        this.id = id;
        this.username = username;
        this.publicKey = publicKey;
        this.joinedAt = joinedAt;
        this.encodedProfilePic = encodedProfilePic;
    }

    public Account( String username, String publicKey, LocalDateTime joinedAt ) {
        this.id = 0L;
        this.username = username;
        this.publicKey = publicKey;
        this.joinedAt = joinedAt;
    }

    public List<Chat> chats() {
        return chatToAccounts.stream().map( ChatToAccount::chat ).toList();
    }

    public List<Friendship> friendships() {
        List<Friendship> friendships = new ArrayList<>( incomingFriendships );
        friendships.addAll( outgoingFriendships );
        return friendships;
    }

    public Optional<Friendship> getIncomingFriendshipWith( Account other ) {
        return incomingFriendships.stream().filter( f -> f.fromAccount.id.equals(other.id) ).findAny();
    }

    public boolean isFriendsWith( Account other ) {
        return friendshipWith( other ).isPresent();
    }

    public Optional<Friendship> friendshipWith( Account other ) {
        return friendships()
                .stream()
                .filter( Friendship::accepted )
                .filter( friendship -> friendship.toAccount().id() == other.id() && friendship.fromAccount.id() == id() || friendship.fromAccount().id() == other.id() && friendship.toAccount.id() == id() )
                .findAny();
    }

    public long id() {
        return id;
    }

    public void setId( long id ) {
        this.id = id;
    }

    public String username() {
        return username;
    }

    public void setUsername( String username ) {
        this.username = username;
    }

    public String publicKey() {
        return publicKey;
    }

    public void setPublicKey( String publicKey ) {
        this.publicKey = publicKey;
    }

    public LocalDateTime joinedAT() {
        return joinedAt;
    }

    public void setJoinedAt( LocalDateTime joinedAt ) {
        this.joinedAt = joinedAt;
    }

    public List<ChatToAccount> chatToAccounts() {
        return chatToAccounts;
    }

    public void setChatToAccounts( List<ChatToAccount> chatToAccounts ) {
        this.chatToAccounts = chatToAccounts;
    }

    public List<Friendship> incomingFriendships() {
        return incomingFriendships;
    }

    public void setIncomingFriendships( List<Friendship> incomingFriendships ) {
        this.incomingFriendships = incomingFriendships;
    }

    public List<Friendship> outgoingFriendships() {
        return outgoingFriendships;
    }

    public void setOutgoingFriendships( List<Friendship> outgoingFriendships ) {
        this.outgoingFriendships = outgoingFriendships;
    }

    public String encodedProfilePic() {
        return encodedProfilePic;
    }

    public void setEncodedProfilePic( String encodedProfilePic ) {
        this.encodedProfilePic = encodedProfilePic;
    }


}
