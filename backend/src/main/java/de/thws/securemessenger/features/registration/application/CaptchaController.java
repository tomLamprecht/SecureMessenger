package de.thws.securemessenger.features.registration.application;

import de.thws.securemessenger.features.registration.logic.CaptchaGenerator;
import de.thws.securemessenger.features.registration.logic.CaptchaSelector;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import java.util.Optional;

@RestController
@RequestMapping("/captcha")
public class CaptchaController {

    private final CaptchaGenerator captchaGenerator;
    private final CaptchaSelector captchaSelector;

    public CaptchaController(CaptchaGenerator captchaGenerator, CaptchaSelector captchaSelector) {
        this.captchaGenerator = captchaGenerator;
        this.captchaSelector = captchaSelector;
    }

    @GetMapping()
    public ResponseEntity<String> getNewCaptcha() {
        return ResponseEntity
                .ok()
                .body(captchaGenerator.createNewCaptchaImage());
    }

    @GetMapping(value = "/{id}", produces = MediaType.IMAGE_PNG_VALUE)
    public ResponseEntity<StreamingResponseBody> getCaptchaImage( @PathVariable String id) {
        Optional<StreamingResponseBody> responseStream = captchaSelector.loadCaptchaImageById(id);
        return responseStream.map(streamingResponseBody -> ResponseEntity
                .ok()
                .contentType(MediaType.IMAGE_PNG)
                .body(streamingResponseBody))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
