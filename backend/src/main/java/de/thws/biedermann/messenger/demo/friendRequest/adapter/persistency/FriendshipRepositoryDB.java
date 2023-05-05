package de.thws.biedermann.messenger.demo.friendRequest.adapter.persistency;

import de.thws.biedermann.messenger.demo.friendRequest.model.Friendship;
import de.thws.biedermann.messenger.demo.friendRequest.repository.FriendshipRepository;

import java.sql.*;
import java.util.LinkedList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component
public class FriendshipRepositoryDB implements FriendshipRepository {

    private static final String url = "jdbc:postgresql://localhost:5432/mydatabase";
    private static final String user = "postgres";
    private static final String password = "mysecretpassword";

    private static final Logger logger = LoggerFactory.getLogger(FriendshipRepositoryDB.class);


    @Override
    public CompletableFuture<List<Friendship>> getAllFriendshipsByUserId(long userId) {
        return CompletableFuture.supplyAsync(() -> {
            try (Connection conn = DriverManager.getConnection(url, user, password)) {
                PreparedStatement statement = conn.prepareStatement("SELECT * FROM friendship WHERE fromUserId = ? OR toUserId = ?;");
                statement.setLong(1, userId);
                statement.setLong(2, userId);
                ResultSet result = statement.executeQuery();
                LinkedList<Friendship> friendships = new LinkedList<>();
                while (result.next()) {
                    long fromUserId = result.getLong("fromUserId");
                    long toUserId = result.getLong("toUserId");
                    boolean accepted = result.getBoolean("accepted");
                    friendships.add(new Friendship(fromUserId, toUserId, accepted));
                }
                return friendships;
            } catch (SQLException e) {
                logger.error("Error while selecting friendships", e);
                throw new RuntimeException(e);
            }
        });
    }

    @Override
    public CompletableFuture<Optional<Friendship>> getFriendship(long fromUserId, long toUserId) {
        return CompletableFuture.supplyAsync(() -> {
            try (Connection conn = DriverManager.getConnection(url, user, password)) {
                PreparedStatement statement = conn.prepareStatement("SELECT * FROM friendship WHERE fromUserId = ? AND toUserId = ?;");
                statement.setLong(1, fromUserId);
                statement.setLong(2, toUserId);
                ResultSet result = statement.executeQuery();
                return Optional.of(new Friendship(result.getLong("fromUserId"), result.getLong("toUserId"), result.getBoolean("accepted")));
            } catch (SQLException e) {
                logger.error("Error while selecting friendship", e);
                return Optional.empty();
            }
        });
    }

    @Override
    public CompletableFuture<Optional<Long>> createFriendship(Friendship friendshipRequest) {
        return CompletableFuture.supplyAsync(() -> {
            try (Connection conn = DriverManager.getConnection(url, user, password)) {
                PreparedStatement statement = conn.prepareStatement("INSERT INTO friendship (fromUserId, toUserId) VALUES (?, ?) RETURNING id;");
                statement.setLong(1, friendshipRequest.fromUserId());
                statement.setLong(2, friendshipRequest.toUserId());
                ResultSet result = statement.executeQuery();
                if (result.next()) {
                    return Optional.of(result.getLong("id"));
                }
                return Optional.empty();
            } catch (SQLException e) {
                logger.error("Error while creating new friendship", e);
                throw new RuntimeException(e);
            }
        });
    }

    @Override
    public CompletableFuture<Integer> deleteFriendship(long fromUserId, long toUserId) {
        return CompletableFuture.supplyAsync(() -> {
            try (Connection conn = DriverManager.getConnection(url, user, password)) {
                PreparedStatement statement = conn.prepareStatement("DELETE FROM friendship WHERE fromUserId = ? AND toUserId = ?;");
                statement.setLong(1, fromUserId);
                statement.setLong(2, toUserId);
                return statement.executeUpdate();
            } catch (SQLException e) {
                logger.error("Error while deleting new friendship", e);
                return 0;
            }
        });
    }
}
