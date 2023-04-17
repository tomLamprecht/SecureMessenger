package de.thws.biedermann.messenger.demo;

import de.thws.biedermann.messenger.demo.authorization.adapter.CurrentUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GetTest {

    private final Logger logger = LoggerFactory.getLogger(GetTest.class);
    private final CurrentUser currentUser;

    @Autowired
    public GetTest( CurrentUser currentUser ) {
        this.currentUser = currentUser;
    }

    @GetMapping("/testinterceptor")
    public String getTest() {
        logger.info("Test");
        return """
                <html>
                <head>
                <title>Test</title>
                </head
                <body>
                <p>Hello World, """
                + currentUser.getUser().username() +
                """
                </p>
                </body>
                </html>
                """;

    }
}
