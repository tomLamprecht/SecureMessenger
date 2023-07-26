CREATE TABLE IF NOT EXISTS Captcha (
    Id VARCHAR(36) PRIMARY KEY,
    Content BYTEA NOT NULL,
    Text VARCHAR(10) NOT NULL,
    ExpirationTime TIMESTAMP NOT NULL DEFAULT now() + INTERVAL '5 minutes'
    );