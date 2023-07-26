package de.thws.securemessenger.registration;

import de.thws.securemessenger.TestBase;
import de.thws.securemessenger.repositories.implementations.RegistrationInMemoryHandler;
import de.thws.securemessenger.features.registration.models.CaptchaTry;
import de.thws.securemessenger.features.registration.models.UserPayload;
import de.thws.securemessenger.features.registration.models.User;
import de.thws.securemessenger.repositories.IRegistrationDbHandler;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.junit.jupiter.api.Assertions.*;

public class RegistrationTest extends TestBase {

    private final String captchaId = "99ec1e03-ae72-4aae-9082-a7d8b675ef6f";
    private final String captchaText = "gGZbcCj";
    private final IRegistrationDbHandler registrationDbHandler;

    @Autowired
    public RegistrationTest(IRegistrationDbHandler registrationDbHandler) {
        this.registrationDbHandler = registrationDbHandler;
    }

    @BeforeAll
    void initTest() {
        if (registrationDbHandler instanceof RegistrationInMemoryHandler){
            ((RegistrationInMemoryHandler) registrationDbHandler).captchaStorage.put(captchaId, captchaText);
        }
    }

    @Test
    void testRegisterUserWithValidArguments() throws Exception {
        UserPayload userPayload = new UserPayload(new CaptchaTry(captchaId, captchaText), "testPublicKey", "Test User");
        String requestBody = objectMapper.writeValueAsString(userPayload);

        MvcResult createCaptchaResult = mockMvc.perform(post("/users/register")
                        .content(requestBody)
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isCreated())
                .andReturn();
        Integer userId = Integer.parseInt(createCaptchaResult.getResponse().getContentAsString());
        if (registrationDbHandler instanceof RegistrationInMemoryHandler){
            User userInDb = ((RegistrationInMemoryHandler) registrationDbHandler).accountStorage.get(userId);
            assertEquals(userPayload.userName(), userInDb.userName());
            assertEquals(userPayload.publicKey(), userInDb.publicKey());
        }
    }

    @Test
    void test404ForRegisterUserWithInvalidCaptchaId() throws Exception {
        UserPayload userPayload = new UserPayload(new CaptchaTry("InvalidCaptchaId", captchaText), "testPublicKey", "Test User");
        String requestBody = objectMapper.writeValueAsString(userPayload);

        mockMvc.perform(post("/users/register")
                        .content(requestBody)
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound());
    }

    @Test
    void test400ForRegisterUserWithInvalidCaptchaText() throws Exception {
        UserPayload userPayload = new UserPayload(new CaptchaTry(captchaId, "InvalidCaptchaText"), "testPublicKey", "Test User");
        String requestBody = objectMapper.writeValueAsString(userPayload);

        mockMvc.perform(post("/users/register")
                        .content(requestBody)
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isBadRequest());
    }

    @AfterAll
    void cleanupTest() {
    }

}
