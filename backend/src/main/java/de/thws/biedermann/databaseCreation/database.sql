CREATE TABLE IF NOT EXISTS Captcha (
    Id VARCHAR(36) PRIMARY KEY,
    Content BYTEA NOT NULL,
    Text VARCHAR(10) NOT NULL,
    ExpirationTime TIMESTAMP NOT NULL DEFAULT now() + INTERVAL '5 minutes'
    );

CREATE TABLE IF NOT EXISTS Account (
    Id SERIAL PRIMARY KEY,
    UserName VARCHAR(100) NOT NULL UNIQUE,
    publicKey BIT(512) NOT NULL, -- NOT NULL muss die Gruppe beim Registrierungsprozess entscheiden
    joinedAt TIMESTAMP NOT NULL DEFAULT now()
    );

CREATE TABLE IF NOT EXISTS Friendship (
    FromAccountId INT NOT NULL REFERENCES Account(Id) ON DELETE CASCADE,
    ToAccountId INT NOT NULL REFERENCES Account(Id) ON DELETE CASCADE,
    Accepted BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (FromAccountId, ToAccountId)
    );

CREATE TABLE IF NOT EXISTS Chat (
    Id SERIAL PRIMARY KEY,
--     OwnerId INT NOT NULL REFERENCES Account(Id) ON DELETE CASCADE, -- OwnerId kann nicht von einem anderen Admin rausgeworfen werden
    Name VARCHAR(150) NOT NULL,  -- die Gruppe entscheidet ob es eine Default Value gibt oder man beim erstellen einen Namen mitgeben MUSS + length?
    Description VARCHAR(255),
    CreatedAt TIMESTAMP NOT NULL DEFAULT now()
    );

CREATE TABLE IF NOT EXISTS ChatToAccount (
    Id SERIAL PRIMARY KEY,
    AccountId INT NOT NULL REFERENCES Account(Id) ON DELETE CASCADE,
    ChatId INT NOT NULL REFERENCES Chat(Id) ON DELETE CASCADE,
    Key BIT(256) NOT NULL,
    IsAdmin BOOLEAN NOT NULL DEFAULT FALSE,
    JoinedAt TIMESTAMP NOT NULL DEFAULT now(),
    LeftAt TIMESTAMP DEFAULT NULL
    );

CREATE TABLE IF NOT EXISTS Message (
    Id SERIAL PRIMARY KEY,
    FromAccountId INT NOT NULL REFERENCES Account(Id) ON DELETE CASCADE,
    ChatId INT NOT NULL REFERENCES Chat(Id) ON DELETE CASCADE,
    Message VARCHAR(1000) NOT NULL, -- length?
    Timestamp TIMESTAMP NOT NULL DEFAULT now()
    );

-- DROP SCHEMA public CASCADE;
-- CREATE SCHEMA public;
-- GRANT ALL ON SCHEMA public TO postgres;
-- GRANT ALL ON SCHEMA public TO public;
