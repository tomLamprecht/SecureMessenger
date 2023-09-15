# Use the official PostgreSQL image as the base image
FROM postgres:latest

# Set environment variables for PostgreSQL
ENV POSTGRES_DB messenger
ENV POSTGRES_USER messenger
ENV POSTGRES_PASSWORD WrP3w336gbR2DIUztKjSF4istgp4b2qHW7E43det

# Copy the SQL file into the container
COPY ./migration/init.sql /docker-entrypoint-initdb.d/