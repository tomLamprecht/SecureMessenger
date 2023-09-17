# SecureMessenger

## Running the Application with Docker

This application is designed to run within a Docker stack. To get started, please follow these steps:

### Prerequisites

- [Docker](https://www.docker.com/get-started) must be installed on your system.

### Start the application

Make sure your docker deamon is running.

To start the application, simply navigate to the root directory of the project and run
   ```shell
   docker-compose up --build
   ```

Docker will build and run the whole application stack.

To terminate the application run
   ```shell
   docker-compose down
   ```