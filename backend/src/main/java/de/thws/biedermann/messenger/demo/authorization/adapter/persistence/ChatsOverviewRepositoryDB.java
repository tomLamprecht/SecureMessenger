package de.thws.biedermann.messenger.demo.authorization.adapter.persistence;
import de.thws.biedermann.messenger.demo.authorization.model.User;
import de.thws.biedermann.messenger.demo.chat.model.Chat;
import de.thws.biedermann.messenger.demo.chat.repository.ChatsOverviewRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;

@Component
public class ChatsOverviewRepositoryDB implements ChatsOverviewRepository {
    private static final String url = "jdbc:postgresql://localhost:5432/mydatabase";
    private static final String user = "postgres";
    private static final String password = "mysecretpassword";

    private static final Logger logger = LoggerFactory.getLogger(ChatsOverviewRepositoryDB.class);

    @Override
    public CompletableFuture<Optional<List<Chat>>> getChats( User clientUser ) {
        return CompletableFuture.supplyAsync(() -> {
            try (Connection conn = DriverManager.getConnection(url, user, password)) {
                PreparedStatement statement = conn.prepareStatement("SELECT * FROM chattoclient " +
                        "LEFT JOIN chat ON chatid = chat.id " +
                        "WHERE userid = ?;");
                statement.setLong(1, clientUser.id());
                ResultSet result = statement.executeQuery();
                List<Chat> chats = new ArrayList<>( );
                while( result.next() ) {
                    chats.add( new Chat( result.getLong("id"), result.getString("name"), result.getString("description"), result.getTimestamp("createdat").toInstant() ) );
                }
                return Optional.of( chats );
            } catch (SQLException e) {
                logger.error("Error while selecting friendship", e);
                return Optional.empty();
            }
        });
    }
}
