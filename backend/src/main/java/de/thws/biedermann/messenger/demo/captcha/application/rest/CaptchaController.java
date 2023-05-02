package de.thws.biedermann.messenger.demo.captcha.application.rest;

import de.thws.biedermann.messenger.demo.captcha.logic.CaptchaGenerator;
import de.thws.biedermann.messenger.demo.captcha.logic.CaptchaSelector;
import de.thws.biedermann.messenger.demo.captcha.logic.CaptchaValidator;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import java.io.IOException;
import java.util.concurrent.ExecutionException;

@RestController
public class CaptchaController {

    @GetMapping(value = "/captcha", produces = MediaType.IMAGE_PNG_VALUE)
    public ResponseEntity<String> getNewCaptcha(HttpServletResponse response) throws IOException, ExecutionException, InterruptedException {
        return ResponseEntity
                .ok()
                .contentType(MediaType.TEXT_PLAIN)
                .body(CaptchaGenerator.createNewCaptchaImage());
    }

    @GetMapping(value = "/captcha/{id}", produces = MediaType.IMAGE_PNG_VALUE)
    public ResponseEntity<StreamingResponseBody> getCaptchaImage(HttpServletResponse response, @PathVariable String id) throws ExecutionException, InterruptedException {
        return ResponseEntity
                .ok()
                .contentType(MediaType.IMAGE_PNG)
                .body(CaptchaSelector.loadCaptchaImageById(id));
    }

    @PostMapping(value = "/captcha/{id}")
    public ResponseEntity<Boolean> validateCaptcha(HttpServletResponse response, @PathVariable String id, @RequestBody String textTry) throws ExecutionException, InterruptedException {

        return ResponseEntity
                .ok()
                .body(CaptchaValidator.isCaptchaValid(id, textTry));
    }
}
