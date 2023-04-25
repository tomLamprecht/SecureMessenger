package de.thws.biedermann.messenger.demo.captcha.controller;

import de.thws.biedermann.messenger.demo.captcha.database.CaptchaDatabaseHandler;
import de.thws.biedermann.messenger.demo.captcha.logic.CaptchaGenerator;
import de.thws.biedermann.messenger.demo.captcha.logic.CaptchaSelector;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import java.io.IOException;
import java.util.concurrent.ExecutionException;

@RestController
public class CaptchaController {

    @GetMapping(value = "/captcha", produces = MediaType.IMAGE_PNG_VALUE)
    public ResponseEntity<String> getNewCaptcha(HttpServletResponse response) throws IOException, ExecutionException, InterruptedException {
        return ResponseEntity.ok()
                .contentType(MediaType.TEXT_PLAIN)
                .body(CaptchaGenerator.createNewCaptchaImage());
    }

    @GetMapping(value = "/captcha/{id}", produces = MediaType.IMAGE_PNG_VALUE)
    public ResponseEntity<StreamingResponseBody> getCaptchaImage(HttpServletResponse response, @PathVariable String id) throws ExecutionException, InterruptedException {
        return ResponseEntity.ok()
                .contentType(MediaType.IMAGE_PNG)
                .body(CaptchaSelector.loadCaptchaImageById(id));
    }
}
