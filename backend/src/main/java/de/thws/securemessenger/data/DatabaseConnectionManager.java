package de.thws.securemessenger.data;

import de.thws.securemessenger.util.throwinglambdas.ThrowingConsumer;
import de.thws.securemessenger.util.throwinglambdas.ThrowingFunction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Supplier;

public abstract class DatabaseConnectionManager {
    private static final String url = "jdbc:postgresql://"+ System.getenv("DB_SERVER") +"/messenger";
    private static final String user = "messenger";
    private static final String password = "WrP3w336gbR2DIUztKjSF4istgp4b2qHW7E43det";

    private static final Logger logger = LoggerFactory.getLogger( DatabaseConnectionManager.class );

    /**
     * Executes a SQL statement asynchronously without expecting a return value.
     * This method is typically used for UPDATE, and DELETE operations.
     *
     * @param statement                  the SQL statement to be executed which is being transformed to a PreparedStatement
     * @param preparedStatementPopulator a {@link Consumer} that sets the values of the
     *                                   {@link PreparedStatement} parameters
     * @return a {@link CompletableFuture} representing the asynchronous
     * operation, which completes when the statement execution is
     * finished and contains the number of updated rows
     * @throws RuntimeException if an {@link SQLException}
     *                          occurs while executing the statement or {@link ClassNotFoundException} when no driver is present
     */
    public static int executeStatementWithoutReturnValue( String statement, ThrowingConsumer<PreparedStatement, SQLException> preparedStatementPopulator ) {
        checkIfDriverIsPresent();
        try ( Connection conn = DriverManager.getConnection( url, user, password ) ) {
            PreparedStatement preparedStatement = conn.prepareStatement( statement );
            preparedStatementPopulator.accept( preparedStatement );
            return preparedStatement.executeUpdate();
        } catch ( SQLException e ) {
            logger.info( "Error storing captcha", e );
            throw new RuntimeException( e );
        }
    }

    /**
     * Executes an SQL INSERT statement asynchronously and returns the generated ID using the
     * "RETURNING id" phrase. The given SQL statement <b>must</b> include the "RETURNING id" phrase
     * to return the ID after the INSERT operation.
     *
     * @param statement                  the SQL INSERT statement to be executed, including
     *                                   the "RETURNING id" phrase
     * @param preparedStatementPopulator a {@link Consumer} that sets the values of the
     *                                   {@link PreparedStatement} parameters
     * @return a {@link CompletableFuture} representing the asynchronous
     * operation, which contains an {@link Optional} of the generated
     * ID when the statement execution is finished, or an empty
     * {@link Optional} if no ID was returned
     * @throws RuntimeException if an {@link SQLException} or {@link ClassNotFoundException}
     *                          occurs while executing the statement
     */
    public static Optional<Integer> insertStatementWithIdReturn( String statement, ThrowingConsumer<PreparedStatement, SQLException> preparedStatementPopulator ) {
        checkIfDriverIsPresent();
        try ( Connection conn = DriverManager.getConnection( url, user, password ) ) {
            PreparedStatement preparedStatement = conn.prepareStatement( statement );
            preparedStatementPopulator.accept( preparedStatement );
            ResultSet result = preparedStatement.executeQuery();
            if ( result.next() )
                return Optional.of( result.getInt( 1 ) );
            else
                return Optional.empty();

        } catch ( SQLException e ) {
            logger.error( "Error inserting Object", e );
            throw new RuntimeException( e );
        }
    }

    /**
     * Executes a SQL statement asynchronously and expects a return value.
     * This method is typically used for SELECT operations.
     *
     * @param statement                  the SQL statement to be executed
     * @param preparedStatementPopulator a {@link Consumer} that sets the values of the
     *                                   {@link PreparedStatement} parameters
     * @return a {@link CompletableFuture} representing the asynchronous
     * operation, which contains a {@link DatabaseResult} when
     * the statement execution is finished
     * @throws RuntimeException if an {@link SQLException} occurs while executing the statement or
     *                          {@link ClassNotFoundException} when no driver is present
     */
    public static DatabaseResult executeStatementWithReturnValue( String statement, ThrowingConsumer<PreparedStatement, SQLException> preparedStatementPopulator ) {
        checkIfDriverIsPresent();
        try ( Connection conn = DriverManager.getConnection( url, user, password ) ) {
            PreparedStatement preparedStatement = conn.prepareStatement( statement );
            preparedStatementPopulator.accept( preparedStatement );
            ResultSet result = preparedStatement.executeQuery();
            return new DatabaseResult( result );
        } catch ( SQLException e ) {
            logger.error( "Error loading captcha text", e );
            throw new RuntimeException( e );
        }
    }

    private static void checkIfDriverIsPresent() {
        try {
            Class.forName( "org.postgresql.Driver" );
        } catch ( ClassNotFoundException e ) {
            throw new RuntimeException( e );
        }
    }

    public static class DatabaseResult {
        private final ResultSet resultSet;

        private DatabaseResult( ResultSet resultSet ) {
            this.resultSet = resultSet;
        }

        /**
         * Converts a single row in a {@link ResultSet} into an object of type T using a provided
         * {@link Function} for converting the row. If the {@link ResultSet} is empty, this method
         * returns an empty Optional.
         *
         * @param <T>             the type of object to be created from the {@link ResultSet}
         * @param resultConverter a {@link Function} that takes a {@link ResultSet} and converts a row
         *                        in the result set to an object of type T
         * @return Optional of type T created from the first row of the {@link ResultSet},
         * or an Optional.Empty if the {@link ResultSet} is empty
         * @throws RuntimeException if an {@link SQLException} occurs while processing the {@link ResultSet}
         */
        public <T> Optional<T> asSingle( ThrowingFunction<ResultSet, T, SQLException> resultConverter ) {
            try {
                if ( resultSet.next() )
                    return Optional.of( resultConverter.apply( resultSet ) );
                else
                    return Optional.empty();
            } catch ( SQLException e ) {
                logger.error( "Error at loading DatabaseResult", e );
                throw new RuntimeException( e );
            }
        }

        /**
         * Converts a {@link ResultSet} into a list of objects using a provided {@link Function} for
         * converting each row in the result set to an object of type T. This overloaded method
         * creates an {@link ArrayList} to store the converted objects.
         *
         * @param <T>             the type of objects contained in the resulting list
         * @param resultConverter a {@link Function} that takes a {@link ResultSet} and converts a row
         *                        in the result set to an object of type T
         * @return a {@link List} containing the objects converted from the {@link ResultSet}
         * @throws RuntimeException if an {@link SQLException} occurs while processing the {@link ResultSet}
         */
        public <T> List<T> asList( ThrowingFunction<ResultSet, T, SQLException> resultConverter ) {
            return asList( ArrayList::new, resultConverter );
        }

        /**
         * Converts a {@link ResultSet} into a list of objects using a provided {@link List} supplier and
         * a {@link Function} for converting each row in the result set to an object of type T.
         *
         * @param <T>             the type of objects contained in the resulting list
         * @param listSupplier    a {@link Supplier} that provides an instance of a {@link List} to store
         *                        the converted objects
         * @param resultConverter a {@link Function} that takes a {@link ResultSet} and converts a row
         *                        in the result set to an object of type T
         * @return a {@link List} containing the objects converted from the {@link ResultSet}
         * @throws RuntimeException if an {@link SQLException} occurs while processing the {@link ResultSet}
         */
        public <T> List<T> asList( Supplier<? extends List<T>> listSupplier, ThrowingFunction<ResultSet, T, SQLException> resultConverter ) {
            List<T> resultList = listSupplier.get();
            try {
                while ( resultSet.next() ) {
                    resultList.add( resultConverter.apply( resultSet ) );
                }
                return resultList;
            } catch ( SQLException e ) {
                logger.error( "Error at loading DatabaseResult", e );
                throw new RuntimeException( e );
            }
        }

    }

}
