package de.thws.securemessenger.captcha;


import de.thws.securemessenger.TestBase;
import de.thws.securemessenger.repositories.CaptchaRepository;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.ArrayList;
import java.util.List;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;

public class CaptchaTest extends TestBase {

    private final CaptchaRepository dbHandler;
    private final List<String> createdCaptchaIds = new ArrayList<>(3);

    @Autowired
    public CaptchaTest(CaptchaRepository dbHandler) {
        this.dbHandler = dbHandler;
    }

   /* @Test
    void testGetNewCaptcha() throws Exception {
        // 1. CaptchaId should be returned
        MvcResult createCaptchaResult = mockMvc.perform(get("/captcha"))
                .andExpect(status().isOk())
                .andReturn();
        String captchaId = createCaptchaResult.getResponse().getContentAsString();
        this.createdCaptchaIds.add(captchaId);

        // 2. Captcha should exist in the database
        Optional<String> captchaTextInDb = dbHandler.loadCaptchaTextById(captchaId);
        Assertions.assertTrue(captchaTextInDb.isPresent());

        // 3. DbEntry should have an image in the database
        Optional<BufferedImage> imageInDb = dbHandler.loadCaptchaImageById(captchaId);
        Assertions.assertTrue(imageInDb.isPresent());

        // 4. Controller should return the same image as the db
        BufferedImage expectedImage = dbHandler.loadCaptchaImageById(captchaId).get();
        mockMvc.perform(get("/captcha/{id}", captchaId)
                        .contentType(MediaType.IMAGE_PNG)
                        .accept(MediaType.IMAGE_PNG))
                .andExpect(status().isOk())
                .andReturn();
    }

    @AfterAll
    void cleanup() {
        createdCaptchaIds.forEach(this.dbHandler::deleteCaptchaById);
    }*/

}
