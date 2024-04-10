# SecureMessenger

## Overview

SecureMessenger is a study project developed by students at Technische Hochschule Würzburg Schweinfurt. The project was initiated to provide a secure, privacy-focused messaging platform. Utilizing End-to-End Encryption (E2EE) with modern Key Exchange protocols such as Elliptic Curve Diffie-Hellman (ECDH), the application ensures that message confidentiality is maintained.

## Security Features

The primary feature of SecureMessenger is its Certificate-based encryption mechanism. This feature was designed so that messages are encrypted in such a way that they can only be decrypted by the intended recipient with the corresponding certificate. If this certificate is lost, the messages cannot be decrypted, highlighting a design where user security is paramount.

## Open Source Transparency

By being open-source, SecureMessenger allowed users to verify the absence of backdoors, providing an alternative to other messaging services where such verification isn't possible. This transparency ensured that the security of messages was in the hands of users.

## Architecture

### Authentication

Spring allows the implementation of custom interceptors that are called before every request. This was utilized in the Secure Messenger to implement an Authentication Interceptor. It is integrated into the application through Dependency Injection and at the same time, endpoints that are not allowed to authorize requests are added to a whitelist. For example, at the endpoint for registering a new user, since the user does not yet have credentials, they cannot authenticate themselves.

To authenticate a request, the client must send three header parameters:

    "x-public-key": Base64_encode(public key)
    "x-auth-timestamp": timestamp in UTC according to ISO-8601 format (9 decimal places) ('2007-12-03T10:15:30.000000000Z')
    "x-auth-signature": Base64.encode( ECC.sign( privateKey, SHA256, method#path#timestamp#request-body ) )

The request is authenticated if:

   1. the header parameters are correctly formatted.
   2. the timestamp is not older than 60 seconds.
   3. the signature can be verified with the public key.

This authenticates the account associated with the public key.
If the signature is faulty or outdated, the user receives an error message with the standardized status code 401, which signals that the authorization was not successful. This causes the request to be aborted.

As an additional security measure, rate limiting is implemented. A maximum of 100 requests per second can be sent. Additional requests are rejected with the error code 429 "Too Many Requests". This request limitation, along with the registration process that requires a captcha, makes Distributed Denial of Service (DDoS) attacks more difficult.

### Encryption

To make sure that no data may get decrypted by third parties, modern encryption standard have been utilized during development. For encrypting messages and pictures the application uses AES 256. To make sure that the server is not able to provide any backdoor attack it is essential to make sure that this AES key gets never provided to the Server in plaintext. To accomplish that ECDH 256 has been utilized to share a secret key between the two parties without ever sharing the plaintext key with the server.   


## Getting Started

To start using SecureMessenger:

1. Clone the repository
2. Follow the setup instructions in our documentation
3. Run the application using Docker by running: 
```docker-compose up```
   
## Contribution

We welcome contributions from the community. If you're interested in improving SecureMessenger, please reach out to us or submit a pull request.

## License

SecureMessenger is released under the MIT LICENSE.

## Acknowledgments

- Technische Hochschule Würzburg Schweinfurt
